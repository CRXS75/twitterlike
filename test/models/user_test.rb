require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end



  test "should create user" do
    user = User.new(:username => "first", :email => "first@mail.com", :password => "tototo", :age => 22)
    assert user.save, "Saved the article with params"
  end

  test "should not create user with no email" do
    user = User.new(:username => "second",  :password => "tototo", :age => 22)
    assert_not user.save, "Saved the article with no email"
  end

  test "should not create user with no login" do
    user = User.new(:email => "third@mail.com",  :password => "tototo", :age => 22)
    assert_not user.save, "Saved the article with no login"
  end

  test "should not create user with no password" do
    user = User.new(:email => "third@mail.com", :age => 22)
    assert_not user.save, "Saved the article with no password"
  end

  test "should not create user same login" do

    user = User.new(:username => "first", :email => "foh@mail.com", :password => "tototo", :age => 22)
    user.save
    user = User.new(:username => "first", :email => "fourth@mail.com", :password => "tototo", :age => 22)
    assert_not user.save, "Saved the article with same login"
  end

end
