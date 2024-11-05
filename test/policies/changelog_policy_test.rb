# frozen_string_literal: true

require "test_helper"

class ChangelogPolicyTest < ActiveSupport::TestCase
  setup do
    @changelog = changelogs(:one)
  end

  test "changelog index viewable by all" do
    assert_predicate ChangelogPolicy.new(nil, Changelog), :index?
  end

  test "changelog show viewable by all" do
    assert_predicate ChangelogPolicy.new(nil, @changelog), :show?
  end
end
