require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  setup do
    @user = User.create(:username => 'toto', :email => 'toto@mail.com', :password => 'tototo', :age => 42)
    @micropost = Micropost.create(:content => "Ceci est un post", :user_id => @user.id)
  end

  test "should create comment" do
    sql_parts = ["INSERT INTO comments (content, user_id, micropost_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?)", "Ceci est un comment", @user.id, @micropost.id, Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    id = ApplicationRecord.connection.insert(sql)
    assert_not_empty Micropost.find_by_sql(['SELECT  "comments".* FROM "comments" WHERE "comments"."id" = ? LIMIT 1', id]), "Save correct comment"
  end

  test "should update comment" do
    sql_parts = ["INSERT INTO comments (content, user_id, micropost_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?)", "Ceci est un comment", @user.id, @micropost.id, Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    id = ApplicationRecord.connection.insert(sql)

    content = "Ceci est un update de comment"
    sql_parts = ["UPDATE comments SET content = ?, updated_at = ?", content, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    ApplicationRecord.connection.execute(sql)
    comment = Comment.find_by_sql(['SELECT "comments".* FROM "comments" WHERE "comments"."id" = ? LIMIT 1', id])[0]
    assert_match content, comment.content, "Have updated"
  end

  test "should destroy comment" do
    sql_parts = ["INSERT INTO comments (content, user_id, micropost_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?)", "Ceci est un comment", @user.id, @micropost.id, Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    id = ApplicationRecord.connection.insert(sql)

    sql_parts = ["DELETE FROM comments WHERE id = ?", id]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    ApplicationRecord.connection.execute(sql)

    assert_empty Comment.find_by_sql(['SELECT "comments".* FROM "comments" WHERE "comments"."id" = ? LIMIT 1', id]), "Destroy comment"

  end

end
