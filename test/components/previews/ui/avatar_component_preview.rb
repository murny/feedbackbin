# frozen_string_literal: true

module Ui
  # @label Avatar
  class AvatarComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      render Ui::AvatarComponent.new(
        src: "https://avatars.githubusercontent.com/u/1930474?v=4",
        alt: "User Avatar"
      )
    end

    # @label All Sizes
    def sizes
      render_with_template locals: {
        sizes: Ui::AvatarComponent::SIZES,
        avatar_url: "https://avatars.githubusercontent.com/u/1930474?v=4"
      }
    end

    # @label Shapes
    def shapes
      render_with_template locals: {
        shapes: Ui::AvatarComponent::SHAPES,
        avatar_url: "https://avatars.githubusercontent.com/u/1930474?v=4"
      }
    end

    # @label With Initials Fallback
    def with_initials
      render Ui::AvatarComponent.new(
        fallback: "John Doe"
      )
    end

    # @label Custom Initials
    def custom_initials
      render Ui::AvatarComponent.new(
        fallback: "AB",
        size: :lg
      )
    end

    # @label No Image (Empty Fallback)
    def no_image
      render Ui::AvatarComponent.new(
        alt: "No image"
      )
    end

    # @label Avatar Group
    def avatar_group
      avatars = [
        { src: "https://avatars.githubusercontent.com/u/1930474?v=4", alt: "User 1" },
        { src: "https://avatars.githubusercontent.com/u/1930474?v=4", alt: "User 2" },
        { src: "https://avatars.githubusercontent.com/u/1930474?v=4", alt: "User 3" },
        { src: "https://avatars.githubusercontent.com/u/1930474?v=4", alt: "User 4" },
        { src: "https://avatars.githubusercontent.com/u/1930474?v=4", alt: "User 5" }
      ]

      render Ui::AvatarGroupComponent.new(
        avatars,
        limit: 3,
        ring: true,
        hover_effect: true
      )
    end

    # @label Avatar Group - With Initials
    def avatar_group_with_initials
      avatars = [
        { fallback: "John Doe" },
        { fallback: "Jane Smith" },
        { fallback: "Bob Johnson" },
        { fallback: "Alice Williams" }
      ]

      render Ui::AvatarGroupComponent.new(
        avatars,
        limit: 3,
        size: :lg,
        ring: true
      )
    end

    # @label Avatar Group - No Limit
    def avatar_group_no_limit
      avatars = [
        { src: "https://avatars.githubusercontent.com/u/1930474?v=4", alt: "User 1" },
        { src: "https://avatars.githubusercontent.com/u/1930474?v=4", alt: "User 2" },
        { src: "https://avatars.githubusercontent.com/u/1930474?v=4", alt: "User 3" }
      ]

      render Ui::AvatarGroupComponent.new(
        avatars,
        ring: true
      )
    end

    # @label Avatar Group - With Hover
    def avatar_group_hover
      avatars = 4.times.map do |i|
        { src: "https://avatars.githubusercontent.com/u/1930474?v=4", alt: "User #{i + 1}" }
      end

      render Ui::AvatarGroupComponent.new(
        avatars,
        hover_effect: true,
        ring: true,
        size: :lg
      )
    end
  end
end
