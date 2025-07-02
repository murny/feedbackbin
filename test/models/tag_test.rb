# frozen_string_literal: true

require "test_helper"

class TagTest < ActiveSupport::TestCase
  def setup
    @organization = organizations(:acme)
    @tag = Tag.new(name: "react", organization: @organization)
  end

  test "should be valid with valid attributes" do
    assert @tag.valid?
  end

  test "should require name" do
    @tag.name = nil
    assert_not @tag.valid?
    assert_includes @tag.errors[:name], "can't be blank"
  end

  test "should normalize name on validation" do
    @tag.name = "React JS Framework"
    @tag.valid?
    assert_equal "react-js-framework", @tag.name
  end

  test "should validate name format" do
    @tag.name = "React@JS"
    assert_not @tag.valid?
    assert_includes @tag.errors[:name], "can only contain lowercase letters, numbers, hyphens, and underscores"
  end

  test "should enforce uniqueness within organization" do
    @tag.save!
    
    duplicate_tag = Tag.new(name: "react", organization: @organization)
    assert_not duplicate_tag.valid?
    assert_includes duplicate_tag.errors[:name], "has already been taken"
  end

  test "should allow same name in different organizations" do
    @tag.save!
    
    other_org = organizations(:other)
    other_tag = Tag.new(name: "react", organization: other_org)
    assert other_tag.valid?
  end

  test "should validate color format" do
    @tag.color = "invalid"
    assert_not @tag.valid?
    assert_includes @tag.errors[:color], "is invalid"
    
    @tag.color = "#ff0000"
    assert @tag.valid?
  end

  test "should use name as param" do
    @tag.name = "react-js"
    assert_equal "react-js", @tag.to_param
  end
end