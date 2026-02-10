# frozen_string_literal: true

require "test_helper"

module Elements
  class AvatarComponentTest < ViewComponent::TestCase
    test "renders avatar with image" do
      render_inline(AvatarComponent.new(
        src: "/test.jpg",
        alt: "Test User"
      ))

      assert_selector "img[src='/test.jpg'][alt='Test User']"
      assert_selector "div[data-slot='avatar']"
      assert_selector "img[data-slot='avatar-image']"
    end

    test "renders all sizes without errors" do
      AvatarComponent::SIZES.each do |size|
        render_inline(AvatarComponent.new(
          src: "/test.jpg",
          size: size
        ))

        assert_selector "div[data-slot='avatar']"
      end
    end

    test "renders all shapes without errors" do
      AvatarComponent::SHAPES.each do |shape|
        render_inline(AvatarComponent.new(
          src: "/test.jpg",
          shape: shape
        ))

        assert_selector "div[data-slot='avatar']"
      end
    end

    test "renders with fallback initials when no image" do
      render_inline(AvatarComponent.new(
        fallback: "AB"
      ))

      assert_selector "div[data-slot='avatar-fallback']", text: "AB"
      assert_no_selector "img"
    end

    test "generates initials from full name" do
      render_inline(AvatarComponent.new(
        fallback: "John Doe"
      ))

      assert_selector "div[data-slot='avatar-fallback']", text: "JD"
    end

    test "generates initials from three-word name" do
      render_inline(AvatarComponent.new(
        fallback: "John Michael Doe"
      ))

      assert_selector "div[data-slot='avatar-fallback']", text: "JM"
    end

    test "handles single-word fallback as-is" do
      render_inline(AvatarComponent.new(
        fallback: "Admin"
      ))

      assert_selector "div[data-slot='avatar-fallback']", text: "Admin"
    end

    test "renders empty fallback when no src and no fallback" do
      render_inline(AvatarComponent.new)

      assert_selector "div[data-slot='avatar-fallback']", text: ""
    end

    test "shows fallback even when image is present" do
      render_inline(AvatarComponent.new(
        src: "/test.jpg",
        fallback: "JD"
      ))

      assert_selector "img[src='/test.jpg']"
      assert_selector "div[data-slot='avatar-fallback']"
    end

    test "applies size BEM class correctly" do
      render_inline(AvatarComponent.new(
        src: "/test.jpg",
        size: :lg
      ))

      assert_selector ".avatar--lg"
    end

    test "applies shape BEM class correctly" do
      render_inline(AvatarComponent.new(
        src: "/test.jpg",
        shape: :square
      ))

      assert_selector ".avatar--square"
    end

    test "merges custom classes" do
      render_inline(AvatarComponent.new(
        src: "/test.jpg",
        class: "custom-class"
      ))

      assert_selector "div.custom-class[data-slot='avatar']"
    end

    test "raises error for invalid size" do
      assert_raises(ArgumentError) do
        AvatarComponent.new(size: :invalid)
      end
    end

    test "raises error for invalid shape" do
      assert_raises(ArgumentError) do
        AvatarComponent.new(shape: :invalid)
      end
    end

    test "includes lazy loading on images" do
      render_inline(AvatarComponent.new(
        src: "/test.jpg"
      ))

      assert_selector "img[loading='lazy']"
    end

    test "uses default alt text when not provided" do
      render_inline(AvatarComponent.new(
        src: "/test.jpg"
      ))

      assert_selector "img[alt='Avatar']"
    end
  end
end
