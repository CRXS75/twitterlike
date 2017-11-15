class User < ApplicationRecord


  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates     :username,  :presence => true,  :length => { in: 3...20 }, :case_sensitive => false, :uniqueness => true
  validates     :email,     :presence => true,  :format => { with: email_regex }, :case_sensitive => false, :uniqueness => true
  validates     :age,       :presence => true,  :numericality => { minimum: 18 }
  validates     :password,  :presence => true,  :length => { minimum: 6 }

  has_many :likes
  has_many :comments
  has_many :microposts, dependent: :destroy
  has_many :active_relationships,  class_name:  "Relationship",
           foreign_key: "follower_id",
           dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
           foreign_key: "followed_id",
           dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower


  has_secure_password

  def self.authenticate(login, submitted_password)


    user = find_by_email(login)
    if user.nil?
      user = find_by_username(login)
    end
    return nil if user.nil?
    return user if user.authenticate(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
               BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

end
