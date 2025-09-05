# frozen_string_literal: true

require "test_helper"

class AdminPolicyTest < ActiveSupport::TestCase
  def setup
    @user_membership = memberships(:feedbackbin_regular_user_one)
    @admin_membership = memberships(:feedbackbin_admin)
  end

  test "admin area access requires admin membership" do
    assert_not_predicate AdminPolicy.new(nil, :admin), :access?
    assert_not_predicate AdminPolicy.new(@user_membership, :admin), :access?

    assert_predicate AdminPolicy.new(@admin_membership, :admin), :access?
  end
end
