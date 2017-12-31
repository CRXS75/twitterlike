require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  setup do
    @first = User.create(:username => 'first', :email => 'first@mail.com', :password => "tototo", :age => 42)
    @second = User.create(:username => 'second', :email => 'second@mail.com', :password => "tototo", :age => 42)
    @third = User.create(:username => 'third', :email => 'third@mail.com', :password => "tototo", :age => 42)
  end

  test "should follow" do
    id = @first.follow(@second)
    assert_not_empty Relationship.find_by_sql(['SELECT "relationships".* FROM "relationships" WHERE "relationships"."id" = ? LIMIT 1', id]), "Save correct relationship"
  end

  test "should unfollow" do
    id = @second.follow(@first)
    @second.unfollow(@first)
    assert_empty Relationship.find_by_sql(['SELECT "relationships".* FROM "relationships" WHERE "relationships"."id" = ? LIMIT 1', id]), "Remove correct relationship"
  end

  test "should validate following" do
    @first.follow(@second)
    assert_equal true, @first.following?(@second)
  end

  test "should not validate following" do
    @first.follow(@third)
    assert_equal false, @first.following?(@second)
  end

end
