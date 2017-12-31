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

  def self.search(search)
    find_by_sql(['SELECT "users".* FROM "users" WHERE "users"."username" LIKE ?', '%' + search + '%']) +
    find_by_sql(['SELECT "users".* FROM "users" WHERE "users"."email" LIKE ?', '%' + search + '%'])
  end

  def follow(nuser)
    sql_parts = ['INSERT INTO "relationships" ("follower_id", "followed_id", "created_at", "updated_at") VALUES (?, ?, ?, ?)', self.id, nuser.id, Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    result = ApplicationRecord.connection.insert(sql)
  end

  def unfollow(nuser)
    sql_parts = ['DELETE FROM "relationships" WHERE "relationships"."follower_id" = ? AND "relationships"."followed_id" = ?', self.id, nuser.id]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    ApplicationRecord.connection.execute(sql)
  end

  def following?(nuser)
    sql_parts = ['SELECT 1 AS one FROM "users" INNER JOIN "relationships" ON "users"."id" = "relationships"."followed_id" WHERE "relationships"."follower_id" = ? AND "users"."id" = ? LIMIT 1', self.id, nuser.id]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    results = ApplicationRecord.connection.execute(sql)
    !results.column_values(0).empty?
  end

  def self.authenticate(login, submitted_password)
    user = User.find_by_sql(['SELECT "users".* FROM "users" WHERE "users"."email" = ? LIMIT 1', login])[0]
    if user.nil?
      user = User.find_by_sql(['SELECT "users".* FROM "users" WHERE "users"."username" = ? LIMIT 1', login])[0]
    end
    return nil if user.nil?
    return user if user.authenticate(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = User.find_by_sql(['SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT 1', id])[0]
    (user && user.salt == cookie_salt) ? user : nil
  end

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
               BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

end
