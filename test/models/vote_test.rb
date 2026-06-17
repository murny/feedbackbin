# frozen_string_literal: true

require "test_helper"

class VoteTest < ActiveSupport::TestCase
  setup do
    @vote = votes(:one)
  end

  test "valid vote" do
    assert_predicate @vote, :valid?
  end

  test "invalid without voter" do
    @vote.voter = nil

    assert_not @vote.valid?
    assert_equal "must exist", @vote.errors[:voter].first
  end

  test "invalid without voteable" do
    @vote.voteable = nil

    assert_not @vote.valid?
    assert_equal "must exist", @vote.errors[:voteable].first
  end

  test "invalid with duplicate voteable_id and voteable_type scoped to voter_id" do
    vote = Vote.new(voter: @vote.voter, voteable: @vote.voteable)

    assert_not vote.valid?
    assert_equal "has already been taken", vote.errors[:voter_id].first
  end

  test "votes are scoped to their account via association" do
    feedbackbin_vote = votes(:one)

    assert_includes accounts(:feedbackbin).votes, feedbackbin_vote
    assert_not_includes accounts(:acme).votes, feedbackbin_vote
  end

  test "acme account scope cannot find a feedbackbin vote" do
    feedbackbin_vote = votes(:one)

    assert_raises(ActiveRecord::RecordNotFound) do
      accounts(:acme).votes.find(feedbackbin_vote.id)
    end
  end

  test "auto-watches idea when user votes on an idea" do
    Current.session = sessions(:shane_chrome)
    Watch.destroy_all

    idea = ideas(:two)
    voter = users(:jane)

    assert_not idea.watched_by?(voter)

    Vote.create!(voter: voter, voteable: idea)

    assert idea.watched_by?(voter)
  end

  test "does not auto-watch when voting on a Comment" do
    Current.session = sessions(:shane_chrome)
    Watch.destroy_all

    comment = comments(:one)
    voter = users(:john)

    assert_no_difference -> { Watch.where(user: voter).count } do
      Vote.create!(voter: voter, voteable: comment)
    end
  end

  test "does not auto-watch for system voter" do
    Current.session = sessions(:shane_chrome)
    Watch.destroy_all

    idea = ideas(:two)
    system_voter = users(:system)

    assert_no_difference -> { Watch.where(user: system_voter, idea: idea).count } do
      Vote.create!(voter: system_voter, voteable: idea)
    end
  end

  test "does not auto-watch for bot voter" do
    Current.session = sessions(:shane_chrome)
    Watch.destroy_all

    idea = ideas(:two)
    bot_voter = users(:bot)

    assert_no_difference -> { Watch.where(user: bot_voter, idea: idea).count } do
      Vote.create!(voter: bot_voter, voteable: idea)
    end
  end
end
