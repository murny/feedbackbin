# frozen_string_literal: true

module Ui
  # @label Avatar
  class AvatarComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      user = create_user_with_avatar
      render Ui::AvatarComponent.new(
        src: user.avatar,
        alt: "User Avatar"
      )
    end

    # @label All Sizes
    def sizes
      user = create_user_with_avatar
      render_with_template locals: {
        sizes: Ui::AvatarComponent::SIZES,
        avatar_url: user.avatar
      }
    end

    # @label Shapes
    def shapes
      user = create_user_with_avatar
      render_with_template locals: {
        shapes: Ui::AvatarComponent::SHAPES,
        avatar_url: user.avatar
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
      user = create_user_with_avatar
      avatars = [
        { src: user.avatar, alt: "User 1" },
        { src: user.avatar, alt: "User 2" },
        { src: user.avatar, alt: "User 3" },
        { src: user.avatar, alt: "User 4" },
        { src: user.avatar, alt: "User 5" }
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
      user = create_user_with_avatar
      avatars = [
        { src: user.avatar, alt: "User 1" },
        { src: user.avatar, alt: "User 2" },
        { src: user.avatar, alt: "User 3" }
      ]

      render Ui::AvatarGroupComponent.new(
        avatars,
        ring: true
      )
    end

    # @label Avatar Group - With Hover
    def avatar_group_hover
      user = create_user_with_avatar
      avatars = 4.times.map do |i|
        { src: user.avatar, alt: "User #{i + 1}" }
      end

      render Ui::AvatarGroupComponent.new(
        avatars,
        hover_effect: true,
        ring: true,
        size: :lg
      )
    end

    private

      def create_user_with_avatar
        user = User.first || User.create!(
          email: "preview@example.com",
          name: "Preview User",
          password: "password",
          password_confirmation: "password"
        )

        unless user.avatar.attached?
          user.avatar.attach(
            io: File.open(Rails.root.join("test/fixtures/files/random.jpeg")),
            filename: "random.jpeg",
            content_type: "image/jpeg"
          )
        end

        user
      end
  end
end
