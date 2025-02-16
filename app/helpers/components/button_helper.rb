module Components
  module ButtonHelper
    def render_button(label = "", text: nil, variant: :primary, as: :button, href: nil, size: :medium, data: {}, **options, &block)
      button_classes = "btn"

      variant_classes = case variant.to_sym
      when :primary
        "btn--primary"
      when :secondary
        "btn--secondary"
      when :outline
        "btn--outline"
      when :danger, :destructive
        "btn--danger"
      when :plain
        "btn--plain"
      end

      size_classes = case size.to_sym
      when :small
        "btn--sm"
      when :medium
        "" # Default size, no additional class needed
      when :large
        "btn--lg"
      end

      button_classes = [ button_classes, variant_classes, size_classes, options[:class] ].reject(&:blank?).join(" ")

      text = label if label.present?
      text = capture(&block) if block

      render "components/ui/button",
             text: text,
             button_classes: button_classes,
             as: as,
             href: href,
             data: data,
             **options
    end
  end
end
