# frozen_string_literal: true

require "test_helper"

# Note: This test assumes the Tag model exists and includes Tag::Attachable.
# If Tag model is not yet created, these tests will be skipped.
class Tag::AttachableTest < ActiveSupport::TestCase
  setup do
    skip "Tag model not yet available" unless defined?(Tag)
    @tag = tags(:feature)
  end

  test "tag includes ActionText::Attachable" do
    assert Tag.include?(ActionText::Attachable)
  end

  test "attachable_plain_text_representation returns hashtag format" do
    assert_equal "##{@tag.name}", @tag.attachable_plain_text_representation
  end

  test "to_attachable_partial_path returns tags/reference" do
    assert_equal "tags/reference", @tag.to_attachable_partial_path
  end

  test "tag has attachable_sgid" do
    assert_respond_to @tag, :attachable_sgid
    assert_not_nil @tag.attachable_sgid
  end
end
