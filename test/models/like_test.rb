require 'test_helper'

class LikeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  setup do
    @user = User.create(:username => 'toto', :email => 'toto@mail.com', :password_digest => User.digest('tototo'), :age => 42)
    @micropost = Micropost.create(:content => "Ceci est un post", :user_id => @user.id)
    @comment = Comment.create(:content => "Ceci est un commentaire", :user_id => @user_id, :micropost_id => @micropost.id)
  end

  test "should create like for post" do
    sql_parts = ["INSERT INTO likes (micropost_id, user_id, created_at, updated_at) VALUES (?, ?, ?, ?)", @micropost.id, @user.id, Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    id = ApplicationRecord.connection.insert(sql)

    assert_not_empty Like.find_by_sql(['SELECT "likes".* FROM "likes" WHERE "likes"."id" = ? LIMIT 1', id]), "Save like for post"
  end

  test "should create like for comment" do
    sql_parts = ["INSERT INTO likes (comment_id, user_id, created_at, updated_at) VALUES (?, ?, ?, ?)", @comment.id, @user.id, Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    id = ApplicationRecord.connection.insert(sql)

    assert_not_empty Like.find_by_sql(['SELECT "likes".* FROM "likes" WHERE "likes"."id" = ? LIMIT 1', id]), "Save like for comment"
  end

  test "should destroy like for post" do
    sql_parts = ["INSERT INTO likes (micropost_id, user_id, created_at, updated_at) VALUES (?, ?, ?, ?)", @micropost.id, @user.id, Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    id = ApplicationRecord.connection.insert(sql)

    sql_parts = ["DELETE FROM likes WHERE id = ?", id]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    ApplicationRecord.connection.execute(sql)

    assert_empty Like.find_by_sql(['SELECT "likes".* FROM "likes" WHERE "likes"."id" = ? LIMIT 1', id]), "Destroy like for post"
  end

  test "should destroy like for comment" do
    sql_parts = ["INSERT INTO likes (comment_id, user_id, created_at, updated_at) VALUES (?, ?, ?, ?)", @comment.id, @user.id, Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    id = ApplicationRecord.connection.insert(sql)

    sql_parts = ["DELETE FROM likes WHERE id = ?", id]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    ApplicationRecord.connection.execute(sql)

    assert_empty Like.find_by_sql(['SELECT "likes".* FROM "likes" WHERE "likes"."id" = ? LIMIT 1', id]), "Destroy like for comment"
  end


end
