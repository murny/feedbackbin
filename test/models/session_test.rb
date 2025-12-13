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
    @session.identity = nil

    assert_not @session.valid?
    assert_equal "must exist", @session.errors[:identity].first
  end

  test "before create sets last active at" do
    identity = identities(:one_identity)
    session = identity.sessions.create!(user_agent: "Mozilla/5.0", ip_address: "127.0.0.1", current_account: accounts(:feedbackbin))

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
