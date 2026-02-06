# frozen_string_literal: true

require "test_helper"

class Tag::AttachableTest < ActiveSupport::TestCase
  setup do
    @tag = tags(:feature)
  end

  test "tag includes ActionText::Attachable" do
    assert_includes Tag, ActionText::Attachable
  end

  test "attachable_plain_text_representation returns hashtag format" do
    assert_equal @tag.hashtag, @tag.attachable_plain_text_representation
  end

  test "to_attachable_partial_path returns tags/reference" do
    assert_equal "tags/reference", @tag.to_attachable_partial_path
  end

  test "tag has attachable_sgid" do
    assert_respond_to @tag, :attachable_sgid
    assert_not_nil @tag.attachable_sgid
  end
end
