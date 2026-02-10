# frozen_string_literal: true

require "test_helper"

module Elements
  class AvatarGroupComponentTest < ViewComponent::TestCase
    test "renders avatar group with all avatars" do
      avatars = [
        { src: "/user1.jpg", alt: "User 1" },
        { src: "/user2.jpg", alt: "User 2" }
      ]

      render_inline(AvatarGroupComponent.new(avatars))

      assert_selector "img[src='/user1.jpg']"
      assert_selector "img[src='/user2.jpg']"
    end

    test "limits number of avatars displayed" do
      avatars = [
        { src: "/user1.jpg", alt: "User 1" },
        { src: "/user2.jpg", alt: "User 2" },
        { src: "/user3.jpg", alt: "User 3" },
        { src: "/user4.jpg", alt: "User 4" }
      ]

      render_inline(AvatarGroupComponent.new(avatars, limit: 2))

      assert_selector "img[src='/user1.jpg']"
      assert_selector "img[src='/user2.jpg']"
      assert_no_selector "img[src='/user3.jpg']"
      assert_no_selector "img[src='/user4.jpg']"
    end

    test "shows remaining count when limit exceeded" do
      avatars = 5.times.map { |i| { src: "/user#{i}.jpg", alt: "User #{i}" } }

      render_inline(AvatarGroupComponent.new(avatars, limit: 3))

      assert_selector "div[data-slot='avatar-fallback']", text: "+2"
    end

    test "does not show remaining count when under limit" do
      avatars = [
        { src: "/user1.jpg", alt: "User 1" },
        { src: "/user2.jpg", alt: "User 2" }
      ]

      render_inline(AvatarGroupComponent.new(avatars, limit: 3))

      assert_no_text "+1"
    end

    test "applies hover effect classes when enabled" do
      avatars = [ { src: "/user1.jpg", alt: "User 1" } ]

      render_inline(AvatarGroupComponent.new(avatars, hover_effect: true))

      assert_selector ".avatar-group--hover"
    end

    test "applies ring classes when enabled" do
      avatars = [ { src: "/user1.jpg", alt: "User 1" } ]

      render_inline(AvatarGroupComponent.new(avatars, ring: true))

      assert_selector ".avatar--ring"
    end

    test "passes size to child avatars" do
      avatars = [ { src: "/user1.jpg", alt: "User 1" } ]

      render_inline(AvatarGroupComponent.new(avatars, size: :lg))

      assert_selector ".avatar--lg"
    end

    test "renders group with initials fallbacks" do
      avatars = [
        { fallback: "John Doe" },
        { fallback: "Jane Smith" }
      ]

      render_inline(AvatarGroupComponent.new(avatars))

      assert_selector "div[data-slot='avatar-fallback']", text: "JD"
      assert_selector "div[data-slot='avatar-fallback']", text: "JS"
    end

    test "merges custom classes with container" do
      avatars = [ { src: "/user1.jpg", alt: "User 1" } ]

      render_inline(AvatarGroupComponent.new(avatars, class: "custom-container"))

      assert_selector ".avatar-group.custom-container"
    end
  end
end
