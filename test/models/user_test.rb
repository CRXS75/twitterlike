require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should create user" do
    sql_parts = ["INSERT INTO users (username, email, age, firstname, lastname, phone, password_digest, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                 "user", "email@mail.com", 42, "firstname", "lastname", "061529634578", User.digest("password"), Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    id = ApplicationRecord.connection.insert(sql)

    assert_not_empty User.find_by_sql(['SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT 1', id]), "Save correct user"
  end


end
