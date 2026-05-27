# frozen_string_literal: true

module Elements
  class EmptyStateComponent < BaseComponent
    VARIANTS = %i[default compact inline page].freeze

    renders_one :cta

    def initialize(
      icon:,
      title:,
      description: nil,
      variant: :default,
      **attrs
    )
      @icon        = icon
      @title       = title
      @description = description
      @variant     = validate_option(variant, VARIANTS, "variant")
      @attrs       = attrs
    end

    private

      def container_attrs
        @attrs.merge(class: empty_state_classes)
      end

      def empty_state_classes
        [
          "empty-state",
          "empty-state--#{@variant}",
          *Array.wrap(@attrs[:class])
        ].compact.join(" ")
      end
  end
end
