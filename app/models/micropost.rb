class Micropost < ApplicationRecord

  include ActiveModel::Serializers::JSON

  validates   :content, :presence => true, :length => { minimum: 1, maximum: 140 }
  belongs_to :user

  has_many :likes
  has_many :comments

  def have_liked(user)
    likes = self.likes
    likes.each do |like|
      if like.user.id == user.id
        return true
      end
    end
    return false
  end

end
