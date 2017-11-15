class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :micropost

  has_many :likes

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
