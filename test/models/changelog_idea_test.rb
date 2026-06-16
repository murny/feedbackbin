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

  # Event emission
  test "creates idea_mentioned_in_changelog event when changelog is already published" do
    published_changelog = changelogs(:two)
    idea = ideas(:three)

    assert_predicate published_changelog, :published?
    assert_difference -> { idea.events.where(action: "idea_mentioned_in_changelog").count }, 1 do
      ChangelogIdea.create!(changelog: published_changelog, idea: idea)
    end

    event = idea.events.where(action: "idea_mentioned_in_changelog").last

    assert_equal published_changelog.id, event.particulars["changelog_id"]
    assert_equal published_changelog.title, event.particulars["changelog_title"]
  end

  test "does not create event when changelog is draft" do
    draft_changelog = Changelog.create!(
      account: accounts(:feedbackbin),
      kind: "improvement",
      title: "Pending publication",
      description: "Drafting"
    )
    idea = ideas(:three)

    assert_not draft_changelog.published?
    assert_no_difference -> { idea.events.where(action: "idea_mentioned_in_changelog").count } do
      ChangelogIdea.create!(changelog: draft_changelog, idea: idea)
    end
  end

  test "publishing a draft changelog with linked ideas backfills events" do
    draft_changelog = changelogs(:draft)
    idea_one = ideas(:one)
    idea_two = ideas(:two)

    initial_one = idea_one.events.where(action: "idea_mentioned_in_changelog").count
    initial_two = idea_two.events.where(action: "idea_mentioned_in_changelog").count

    draft_changelog.update!(published_at: Time.current)

    assert_equal initial_one + 1, idea_one.events.where(action: "idea_mentioned_in_changelog").count
    assert_equal initial_two + 1, idea_two.events.where(action: "idea_mentioned_in_changelog").count

    backfilled = idea_one.events.where(action: "idea_mentioned_in_changelog").last

    assert_equal draft_changelog.id, backfilled.particulars["changelog_id"]
  end

  test "republishing an already-published changelog does not duplicate events" do
    published_changelog = changelogs(:one)
    idea = ideas(:one)

    published_changelog.update!(published_at: nil)
    published_changelog.update!(published_at: Time.current)

    first_pass_count = idea.events.where(action: "idea_mentioned_in_changelog")
                           .select { |e| e.particulars["changelog_id"] == published_changelog.id }
                           .count

    published_changelog.update!(published_at: nil)
    published_changelog.update!(published_at: Time.current)

    second_pass_count = idea.events.where(action: "idea_mentioned_in_changelog")
                            .select { |e| e.particulars["changelog_id"] == published_changelog.id }
                            .count

    assert_equal first_pass_count, second_pass_count
  end
end
