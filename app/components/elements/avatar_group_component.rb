# frozen_string_literal: true

module Elements
  class AvatarGroupComponent < BaseComponent
    def initialize(
      avatars,
      limit: nil,
      size: :default,
      hover_effect: false,
      ring: true,
      **attrs
    )
      @avatars_data = avatars
      @avatars = limit ? avatars.first(limit) : avatars
      @total = avatars.size
      @limit = limit
      @size = size
      @hover_effect = hover_effect
      @ring = ring
      @attrs = attrs
    end

    private

      def html_attrs
        @attrs.merge(class: container_classes)
      end

      def container_classes
        [
          "avatar-group",
          ("avatar-group--hover" if @hover_effect),
          @attrs[:class]
        ].compact.join(" ")
      end

      def remaining_count
        return 0 unless @limit && @total > @limit
        @total - @limit
      end

      def show_remaining?
        @limit && @total > @limit
      end
  end
end
