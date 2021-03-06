require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @user = User.create(:username => 'toto', :email => 'toto@mail.com', :password => 'tototo', :age => 42)
  end

  test "should create post" do
    sql_parts = ["INSERT INTO microposts (content, user_id, created_at, updated_at) VALUES (?, ?, ?, ?)", "Ceci est un post", @user.id, Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    id = ApplicationRecord.connection.insert(sql)
    assert_not_empty Micropost.find_by_sql(['SELECT  "microposts".* FROM "microposts" WHERE "microposts"."id" = ? LIMIT 1', id]), "Save correct post"
  end

  test "should update post" do
    sql_parts = ["INSERT INTO microposts (content, user_id, created_at, updated_at) VALUES (?, ?, ?, ?)", "Ceci est un post", @user.id, Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    id = ApplicationRecord.connection.insert(sql)

    content = "Ceci est un update de post"
    sql_parts = ["UPDATE microposts SET content = ?, updated_at = ? WHERE id = ?", content, Time.now, id]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    ApplicationRecord.connection.execute(sql)
    post = Micropost.find_by_sql(['SELECT  "microposts".* FROM "microposts" WHERE "microposts"."id" = ? LIMIT 1', id])[0]
    assert_match content, post.content, "Have updated"
  end

  test "should destroy post" do
    sql_parts = ["INSERT INTO microposts (content, user_id, created_at, updated_at) VALUES (?, ?, ?, ?)", "Ceci est un post", @user.id, Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    id = ApplicationRecord.connection.insert(sql)

    sql_parts = ["DELETE FROM microposts WHERE id = ?", id]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    ApplicationRecord.connection.execute(sql)

    assert_empty Micropost.find_by_sql(['SELECT  "microposts".* FROM "microposts" WHERE "microposts"."id" = ? LIMIT 1', id]), "Destroy Post"
  end

end
