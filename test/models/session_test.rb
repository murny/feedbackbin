# frozen_string_literal: true

require "test_helper"

class SessionTest < ActiveSupport::TestCase
  def setup
    @session = sessions(:shane_chrome)
  end

  test "valid session" do
    assert_predicate @session, :valid?
  end

  test "invalid without user" do
    @session.user = nil

    assert_not @session.valid?
    assert_equal "must exist", @session.errors[:user].first
  end

  test "dependent destroy on user" do
    user = users(:user)
    user.sessions.create!(user_agent: "Mozilla/5.0", ip_address: "127.0.0.1")

    assert_difference("Session.count", -1) do
      user.destroy
    end
  end

  test "before create sets last active at" do
    user = users(:user)
    session = user.sessions.create!(user_agent: "Mozilla/5.0", ip_address: "127.0.0.1")

    assert_not_nil session.last_active_at
  end

  test "resume updates last active at" do
    freeze_time do
      @session.resume(user_agent: "Mozilla/5.0", ip_address: "127.0.0.1")

      @session.reload

      assert_equal "Mozilla/5.0", @session.user_agent
      assert_equal "127.0.0.1", @session.ip_address
      assert_equal Time.zone.now, @session.last_active_at
    end
  end
end
