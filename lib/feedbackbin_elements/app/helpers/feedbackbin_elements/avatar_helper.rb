# frozen_string_literal: true

module FeedbackbinElements
  module AvatarHelper
    def render_avatar(src: nil, alt: nil, size: :default, fallback: nil, shape: :circle, **options, &block)
      base_classes = components_avatar_base_class
      size_classes = components_avatar_size_class(size)
      shape_classes = components_avatar_shape_class(shape)
      custom_classes = options[:class]

      # Use the tw_merge helper to intelligently merge classes
      options[:class] = tw_merge(base_classes, size_classes, shape_classes, custom_classes)

      # Generate fallback initials if fallback is a name
      if fallback.is_a?(String) && fallback.strip.include?(" ")
        initials = components_avatar_generate_initials_from_name(fallback)
      else
        initials = fallback
      end

      render "feedbackbin_elements/components/avatar", {
        src: src,
        alt: alt,
        fallback: initials,
        options: options
      }
    end

    def render_avatar_group(avatars, limit: nil, size: :default, hover_effect: false, ring: false, **options)
      container_base_classes = "flex"
      spacing_classes = hover_effect ? "-space-x-2 hover:space-x-1" : "-space-x-2"
      custom_classes = options[:class]

      # Use the tw_merge helper to merge container classes
      options[:class] = tw_merge(container_base_classes, spacing_classes, custom_classes)

      # Additional styles for avatar elements in the group
      item_classes = []
      item_classes << "ring-2 ring-background" if ring
      item_classes << "transition-all duration-300 ease-in-out" if hover_effect

      render "feedbackbin_elements/components/avatar_group", {
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
        ].join(" ")
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

      def components_avatar_generate_initials_from_name(name)
        return "" if name.blank?

        name.strip.split.map(&:first).join("").upcase[0, 2]
      end
  end
end
