# frozen_string_literal: true

require "test_helper"

class AdminPolicyTest < ActiveSupport::TestCase
  def setup
    @regular_user = users(:john)  # member role
    @admin_user = users(:shane)  # admin role
  end

  test "admin area access requires admin role" do
    assert_not_predicate AdminPolicy.new(nil, :admin), :access?
    assert_not_predicate AdminPolicy.new(@regular_user, :admin), :access?

    assert_predicate AdminPolicy.new(@admin_user, :admin), :access?
  end
end
