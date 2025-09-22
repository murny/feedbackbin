# frozen_string_literal: true

require "test_helper"

class InvitationPolicyTest < ActiveSupport::TestCase
  def setup
    @invitation = invitations(:one)
    @user = users(:one)
    @admin_user = users(:shane)
  end

  test "invitation new available if admin" do
    assert_not_predicate InvitationPolicy.new(nil, @invitation), :new?
    assert_not_predicate InvitationPolicy.new(@user, @invitation), :new?

    assert_predicate InvitationPolicy.new(@admin_user, @invitation), :new?
  end

  test "invitation create available if admin" do
    assert_not_predicate InvitationPolicy.new(nil, @invitation), :create?
    assert_not_predicate InvitationPolicy.new(@user, @invitation), :create?

    assert_predicate InvitationPolicy.new(@admin_user, @invitation), :create?
  end
end
