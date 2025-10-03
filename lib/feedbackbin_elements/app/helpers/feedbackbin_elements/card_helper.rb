# frozen_string_literal: true

module FeedbackbinElements
  module CardHelper
    def render_card(title: nil, description: nil, body: nil, footer: nil, header_action: nil, **options, &block)
      base_classes = components_card_base_class
      custom_classes = options[:class]

      # Use the tw_merge helper to intelligently merge classes
      options[:class] = tw_merge(base_classes, custom_classes)

      render "feedbackbin_elements/components/card", {
        title: title,
        description: description,
        body: block_given? ? capture(&block) : body,
        footer: footer,
        header_action: header_action,
        block: block_given?,
        options: options
      }
    end

    private

      def components_card_base_class
        "bg-card text-card-foreground flex flex-col gap-6 rounded-xl border py-6 shadow-sm"
      end
  end
end
