# frozen_string_literal: true

module Ui
  class AvatarGroupComponent < BaseComponent
    def initialize(
      avatars,
      limit: nil,
      size: :default,
      hover_effect: false,
      ring: false,
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
        tw_merge(
          "flex",
          spacing_classes,
          @attrs[:class]
        )
      end

      def spacing_classes
        @hover_effect ? "-space-x-2 hover:space-x-1" : "-space-x-2"
      end

      def avatar_item_classes
        classes = []
        classes << "ring-2 ring-background" if @ring
        classes << "transition-all duration-300 ease-in-out" if @hover_effect
        classes.join(" ")
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
