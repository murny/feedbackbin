# frozen_string_literal: true

require "test_helper"

class VisitTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:feedbackbin)
    @user = users(:shane)
    @idea = ideas(:one)
    Current.account = @account
  end

  test "Visit.record creates a row when none exists" do
    Visit.where(user: @user, idea: @idea).destroy_all

    assert_difference "Visit.count", 1 do
      Visit.record(idea: @idea, user: @user)
    end

    visit = Visit.find_by(user: @user, idea: @idea)

    assert_not_nil visit
    assert_equal @account, visit.account
    assert_in_delta Time.current, visit.visited_at, 5
  end

  test "Visit.record updates visited_at on existing row instead of duplicating" do
    Visit.where(user: @user, idea: @idea).destroy_all
    Visit.record(idea: @idea, user: @user)
    travel_to 1.hour.from_now do
      assert_no_difference "Visit.count" do
        Visit.record(idea: @idea, user: @user)
      end

      visit = Visit.find_by(user: @user, idea: @idea)

      assert_in_delta Time.current, visit.visited_at, 5
    end
  end

  test "Visit.record returns nil when user is nil (anonymous)" do
    assert_no_difference "Visit.count" do
      result = Visit.record(idea: @idea, user: nil)

      assert_nil result
    end
  end

  test "Visit.recent orders by visited_at DESC" do
    Visit.destroy_all
    older = Visit.create!(account: @account, user: @user, idea: ideas(:one), visited_at: 2.hours.ago)
    newer = Visit.create!(account: @account, user: @user, idea: ideas(:two), visited_at: 10.minutes.ago)

    assert_equal [ newer, older ], Visit.recent.to_a
  end

  test "Visit is account-scoped via default Current.account" do
    Visit.destroy_all

    Current.account = accounts(:feedbackbin)
    Visit.record(idea: ideas(:one), user: @user)

    Current.account = accounts(:acme)
    Visit.record(idea: ideas(:acme_one), user: users(:acme_admin))

    Current.account = accounts(:feedbackbin)
    feedbackbin_visits = Visit.where(account: accounts(:feedbackbin))
    acme_visits = Visit.where(account: accounts(:acme))

    assert_equal 1, feedbackbin_visits.count
    assert_equal 1, acme_visits.count
    assert_equal @user, feedbackbin_visits.first.user
    assert_equal users(:acme_admin), acme_visits.first.user
  end
end
