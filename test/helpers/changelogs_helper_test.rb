# frozen_string_literal: true

require "test_helper"

class ChangelogsHelperTest < ActionView::TestCase
  test "new kind resolves to :default variant" do
    assert_equal :default, changelog_badge_variant("new")
  end

  test "fix kind resolves to :destructive variant" do
    assert_equal :destructive, changelog_badge_variant("fix")
  end

  test "improvement kind resolves to :success variant" do
    assert_equal :success, changelog_badge_variant("improvement")
  end

  test "update kind resolves to :warning variant" do
    assert_equal :warning, changelog_badge_variant("update")
  end

  test "unknown kind falls back to :secondary" do
    assert_equal :secondary, changelog_badge_variant("nope")
  end

  test "every Changelog::TYPES value resolves to a valid BadgeComponent variant" do
    Changelog::TYPES.each do |kind|
      assert_includes Elements::BadgeComponent::VARIANTS, changelog_badge_variant(kind)
    end
  end
end
