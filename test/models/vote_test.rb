# frozen_string_literal: true

require "test_helper"

class VoteTest < ActiveSupport::TestCase
  def setup
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
end
