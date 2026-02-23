# frozen_string_literal: true

require "test_helper"

class Idea::TaggableTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    @idea = ideas(:one)
    @account = accounts(:feedbackbin)
  end

  test "toggle_tag_with adds tag when idea does not have it" do
    assert_difference "Tagging.count", 1 do
      @idea.toggle_tag_with("performance")
    end

    assert @idea.reload.tags.exists?(title: "performance")
  end

  test "toggle_tag_with removes tag when idea already has it" do
    @idea.toggle_tag_with("performance")

    assert_difference "Tagging.count", -1 do
      @idea.toggle_tag_with("performance")
    end

    assert_not @idea.reload.tags.exists?(title: "performance")
  end

  test "toggle_tag_with creates the tag if it does not exist" do
    assert_difference "Tag.count", 1 do
      @idea.toggle_tag_with("brand-new-tag")
    end
  end

  test "toggle_tag_with reuses existing tag for same account" do
    @idea.toggle_tag_with("feature")

    assert_no_difference "Tag.count" do
      ideas(:two).toggle_tag_with("feature")
    end
  end

  test "tagged_with? returns true when idea has the tag" do
    tag = tags(:feature)
    Tagging.create!(idea: @idea, tag: tag, account: @account)

    assert @idea.tagged_with?(tag)
  end

  test "tagged_with? returns false when idea does not have the tag" do
    assert_not @idea.tagged_with?(tags(:feature))
  end

  test "tagged_with? works with preloaded tags" do
    tag = tags(:feature)
    Tagging.create!(idea: @idea, tag: tag, account: @account)
    @idea.tags.load

    assert @idea.tagged_with?(tag)
  end

  test "tagged_with scope returns ideas with given tag" do
    tag = tags(:feature)
    Tagging.create!(idea: @idea, tag: tag, account: @account)

    tagged_ideas = Idea.tagged_with([tag])

    assert_includes tagged_ideas, @idea
    assert_not_includes tagged_ideas, ideas(:two)
  end

  test "tagged_with scope returns distinct ideas even with multiple matching taggings" do
    tag1 = tags(:feature)
    tag2 = tags(:bug)
    Tagging.create!(idea: @idea, tag: tag1, account: @account)
    Tagging.create!(idea: @idea, tag: tag2, account: @account)

    results = Idea.tagged_with([ tag1, tag2 ])

    assert_equal 1, results.where(id: @idea.id).count
  end
end
