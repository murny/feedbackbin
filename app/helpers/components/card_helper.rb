# frozen_string_literal: true

module Components
  module CardHelper
    def render_card(title: nil, description: nil, body: nil, footer: nil, header_action: nil, **options, &block)
      card_classes = [
        card_ui_base_class,
        options[:class]
      ].flatten.compact.join(" ")

      # Update options with the combined card_classes
      options[:class] = card_classes

      render "components/ui/card", {
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

      def card_ui_base_class
        [
          "bg-card text-card-foreground flex flex-col gap-6 rounded-xl border py-6 shadow-sm"
        ]
      end
  end
end
