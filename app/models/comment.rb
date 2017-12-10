class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :micropost

  has_many :likes

  def have_liked(user)
    likes = Like.find_by_sql(['SELECT "likes".* FROM "likes" WHERE "likes"."comment_id" = ?', self.id])
    likes.each do |like|
      if like.user.id == user.id
        return true
      end
    end
    return false
  end

end
