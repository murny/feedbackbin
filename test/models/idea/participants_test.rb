# frozen_string_literal: true

require "test_helper"

class Idea::ParticipantsTest < ActiveSupport::TestCase
  def setup
    Current.session = sessions(:shane_chrome)
  end

  test "returns creator first followed by commenters ordered by most recent activity" do
    idea = Idea.create!(title: "Test idea", board: boards(:one), creator: users(:shane))
    old_comment = Comment.create!(idea: idea, creator: users(:jane), account: accounts(:feedbackbin), body: "Old comment")
    old_comment.update_column(:created_at, 2.days.ago)
    Comment.create!(idea: idea, creator: users(:john), account: accounts(:feedbackbin), body: "New comment")

    result = idea.participants

    assert_equal [ users(:shane), users(:john), users(:jane) ], result
  end

  test "excludes duplicates when user has multiple comments" do
    idea = ideas(:one)

    participant_ids = idea.participants.pluck(:id)

    assert_equal participant_ids, participant_ids.uniq
  end

  test "only includes users from the same account" do
    idea = ideas(:one)
    other_account_user = users(:acme_admin)

    assert_not_includes idea.participants, other_account_user
  end

  test "excludes inactive users including creator" do
    idea = Idea.create!(title: "Test idea", board: boards(:one), creator: users(:jane))
    Comment.create!(idea: idea, creator: users(:john), account: accounts(:feedbackbin), body: "Comment")
    idea.creator.update!(active: false)

    result = idea.reload.participants

    assert_not_includes result, users(:jane)
    assert_equal [ users(:john) ], result
  end

  test "defaults to limit of 10" do
    idea = ideas(:one)

    result = idea.participants

    assert_operator result.size, :<=, 10
  end

  test "respects custom limit parameter" do
    idea = ideas(:one)

    result = idea.participants(limit: 2)

    assert_operator result.size, :<=, 2
  end

  test "participant_ids returns total count without limit" do
    idea = Idea.create!(title: "Test idea", board: boards(:one), creator: users(:shane))
    Comment.create!(idea: idea, creator: users(:jane), account: accounts(:feedbackbin), body: "Comment")
    Comment.create!(idea: idea, creator: users(:john), account: accounts(:feedbackbin), body: "Comment")

    assert_equal 3, idea.participant_ids.count
  end
end
