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

  test "should not valid user with existing username" do
    sql_parts = ["INSERT INTO users (username, email, age, firstname, lastname, phone, password_digest, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                 "user2", "email2@mail.com", 42, "firstname", "lastname", "061529634578", User.digest("password"), Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    ApplicationRecord.connection.insert(sql)

    user = User.new(:username => "user2", :email => "2email@mail.com", :age => 42, :password => "password")
    assert_equal false, user.valid?
  end

  test "should not valid user with existing email" do
    sql_parts = ["INSERT INTO users (username, email, age, firstname, lastname, phone, password_digest, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                 "user3", "email3@mail.com", 42, "firstname", "lastname", "061529634578", User.digest("password"), Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    ApplicationRecord.connection.insert(sql)

    user = User.new(:username => "3user", :email => "email3@mail.com", :age => 42, :password => "password")
    assert_equal false, user.valid?
  end

  test "should not valid user with too short username" do
    user = User.new(:username => "us", :email => "email4@mail.com", :age => 42, :password => "password")
    assert_equal false, user.valid?
  end

  test "should not valid user with bad email format" do
    user = User.new(:username => "user5", :email => "email4mail.com", :age => 42, :password => "password")
    assert_equal false, user.valid?
  end

  test "should not valid user with too short password" do
    user = User.new(:username => "user6", :email => "email6@mail.com", :age => 42, :password => "pass")
    assert_equal false, user.valid?
  end

  test "find user by username" do
    sql_parts = ["INSERT INTO users (username, email, age, firstname, lastname, phone, password_digest, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                 "user7", "email7@mail.com", 42, "firstname", "lastname", "061529634578", User.digest("password"), Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    ApplicationRecord.connection.insert(sql)
    assert_not_empty User.search("user7")
  end

  test "find user by email" do
    sql_parts = ["INSERT INTO users (username, email, age, firstname, lastname, phone, password_digest, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                 "user8", "email8@mail.com", 42, "firstname", "lastname", "061529634578", User.digest("password"), Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    ApplicationRecord.connection.insert(sql)
    assert_not_empty User.search("email8")
  end

  test "find no user" do
    assert_empty User.search("null")
  end

end
