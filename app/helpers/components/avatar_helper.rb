# frozen_string_literal: true

module Components
  module AvatarHelper
    def render_avatar(src: nil, alt: nil, size: :default, fallback: nil, shape: :circle, **options, &block)
      avatar_classes = [
        components_avatar_base_class,
        components_avatar_size_class(size),
        components_avatar_shape_class(shape),
        options[:class]
      ].flatten.compact.join(" ")

      # Update options with the combined avatar_classes
      options[:class] = avatar_classes

      # Generate fallback initials if fallback is a name
      if fallback.is_a?(String) && fallback.strip.include?(" ")
        initials = generate_initials_from_name(fallback)
      else
        initials = fallback
      end

      render "components/ui/avatar", {
        src: src,
        alt: alt,
        fallback: initials,
        options: options
      }
    end

    def render_avatar_group(avatars, limit: nil, size: :default, hover_effect: false, ring: false, **options)
      container_classes = [
        "flex",
        hover_effect ? "-space-x-2 hover:space-x-1" : "-space-x-2",
        options[:class]
      ].flatten.compact.join(" ")

      # Additional styles for avatar elements in the group
      item_classes = []
      item_classes << "ring-2 ring-background" if ring
      item_classes << "transition-all duration-300 ease-in-out" if hover_effect

      # Update options with the combined container_classes
      options[:class] = container_classes

      render "components/ui/avatar_group", {
        avatars: limit ? avatars.first(limit) : avatars,
        total: avatars.size,
        limit: limit,
        size: size,
        item_classes: item_classes.join(" "),
        ring: ring,
        hover_effect: hover_effect,
        options: options
      }
    end

    private

      def components_avatar_base_class
        [
          "relative flex shrink-0 overflow-hidden",
          # Focus
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        ]
      end

      def components_avatar_size_class(size)
        case size
        when :default
          "size-8" # 32px
        when :sm
          "size-6" # 24px
        when :lg
          "size-12" # 48px
        when :xl
          "size-16" # 64px
        else
          raise ArgumentError, "Unknown avatar size: #{size}"
        end
      end

      def components_avatar_shape_class(shape)
        case shape
        when :circle
          "rounded-full"
        when :square
          "rounded-md"
        else
          raise ArgumentError, "Unknown avatar shape: #{shape}"
        end
      end

      def generate_initials_from_name(name)
        return "" if name.blank?

        name.strip.split.map(&:first).join("").upcase[0, 2]
      end
  end
end
