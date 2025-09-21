# frozen_string_literal: true

require "test_helper"

class Organization
  class TransferableTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    setup do
      @organization = organizations(:feedbackbin)
    end

    test "can_transfer? false in single tenancy mode" do
      assert_not @organization.can_transfer?(users(:shane))
      assert_not @organization.can_transfer?(users(:one))
      assert_not @organization.can_transfer?(nil)
    end

    test "transfer_ownership disabled in single tenancy mode" do
      new_owner = users(:two)

      assert_not @organization.transfer_ownership(new_owner.id)
    end
  end
end
