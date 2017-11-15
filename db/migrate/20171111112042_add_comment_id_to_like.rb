class AddCommentIdToLike < ActiveRecord::Migration[5.0]
  def change
    add_column :likes, :comment_id, :integer
  end
end
