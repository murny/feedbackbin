# frozen_string_literal: true

require "test_helper"

class ReplyTest < ActiveSupport::TestCase
  setup do
    @reply = replies(:one)
  end

  test "valid reply" do
    assert_predicate @reply, :valid?
  end

  test "invalid without body" do
    @reply.body = nil

    assert_not @reply.valid?
    assert_equal "can't be blank", @reply.errors[:body].first
  end

  test "invalid without comment" do
    @reply.comment = nil

    assert_not @reply.valid?
    assert_equal "must exist", @reply.errors[:comment].first
  end

  test "invalid without creator" do
    @reply.creator = nil

    assert_not @reply.valid?
    assert_equal "must exist", @reply.errors[:creator].first
  end
end
