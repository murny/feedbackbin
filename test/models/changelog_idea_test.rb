# frozen_string_literal: true

require "test_helper"

class ChangelogIdeaTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    @changelog_idea = changelog_ideas(:one_to_idea_one)
  end

  test "valid changelog_idea" do
    assert_predicate @changelog_idea, :valid?
  end

  # Associations
  test "belongs to account" do
    assert_equal accounts(:feedbackbin), @changelog_idea.account
  end

  test "belongs to changelog" do
    assert_equal changelogs(:one), @changelog_idea.changelog
  end

  test "belongs to idea" do
    assert_equal ideas(:one), @changelog_idea.idea
  end

  # Uniqueness
  test "invalid with duplicate changelog and idea" do
    duplicate = ChangelogIdea.new(
      account: @changelog_idea.account,
      changelog: @changelog_idea.changelog,
      idea: @changelog_idea.idea
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:idea_id], "has already been taken"
  end

  # attr_readonly
  test "attr_readonly prevents changelog_id update" do
    assert_raises(ActiveRecord::ReadonlyAttributeError) do
      @changelog_idea.update(changelog_id: changelogs(:two).id)
    end
  end

  test "attr_readonly prevents idea_id update" do
    assert_raises(ActiveRecord::ReadonlyAttributeError) do
      @changelog_idea.update(idea_id: ideas(:two).id)
    end
  end

  # Account default
  test "account defaults to Current.account on save" do
    changelog_idea = ChangelogIdea.new(changelog: changelogs(:two), idea: ideas(:two))
    changelog_idea.save!

    assert_equal Current.account, changelog_idea.account
  end
end
