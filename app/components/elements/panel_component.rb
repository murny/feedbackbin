# frozen_string_literal: true

module Elements
  class PanelComponent < BaseComponent
    renders_one :header, lambda { |title: nil, description: nil, **attrs|
      HeaderComponent.new(title: title, description: description, **attrs)
    }
    renders_one :body, lambda { |**attrs|
      BodyComponent.new(**attrs)
    }
    renders_one :footer, lambda { |**attrs|
      FooterComponent.new(**attrs)
    }

    def initialize(bordered: false, compact: false, **attrs)
      @bordered = bordered
      @compact = compact
      @attrs = attrs
    end

    def call
      tag.div(**panel_attrs) do
        safe_join([ header, body, footer ].compact)
      end
    end

    private

      def panel_attrs
        {
          data: (@attrs[:data] || {}).merge(slot: "panel"),
          class: panel_classes
        }.merge(@attrs.except(:class, :data))
      end

      def panel_classes
        [
          "panel",
          ("panel--bordered" if @bordered),
          ("panel--compact" if @compact),
          @attrs[:class]
        ].compact.join(" ")
      end

      # Header subcomponent
      class HeaderComponent < BaseComponent
        def initialize(title: nil, description: nil, **attrs)
          @title = title
          @description = description
          @attrs = attrs
        end

        def call
          tag.header(**header_attrs) do
            if content.present?
              text_content = render_text_content
              if text_content.present?
                safe_join([
                  tag.div { text_content },
                  tag.div(class: "panel__action", data: { slot: "panel-action" }) { content }
                ])
              else
                tag.div(class: "panel__action", data: { slot: "panel-action" }) { content }
              end
            else
              render_text_content
            end
          end
        end

        private

          def header_attrs
            {
              data: (@attrs[:data] || {}).merge(slot: "panel-header"),
              class: header_classes
            }.merge(@attrs.except(:class, :data))
          end

          def header_classes
            [ "panel__header", @attrs[:class] ].compact.join(" ")
          end

          def render_text_content
            parts = [ render_title, render_description ].compact
            return nil if parts.empty?

            safe_join(parts)
          end

          def render_title
            return nil unless @title.present?

            tag.h2(@title, class: "panel__title", data: { slot: "panel-title" })
          end

          def render_description
            return nil unless @description.present?

            tag.p(@description, class: "panel__description", data: { slot: "panel-description" })
          end
      end

      # Body subcomponent
      class BodyComponent < BaseComponent
        def initialize(**attrs)
          @attrs = attrs
        end

        def call
          tag.section(**body_attrs) { content }
        end

        private

          def body_attrs
            {
              data: (@attrs[:data] || {}).merge(slot: "panel-content"),
              class: body_classes
            }.merge(@attrs.except(:class, :data))
          end

          def body_classes
            [ "panel__body", @attrs[:class] ].compact.join(" ")
          end
      end

      # Footer subcomponent
      class FooterComponent < BaseComponent
        def initialize(**attrs)
          @attrs = attrs
        end

        def call
          tag.footer(**footer_attrs) { content }
        end

        private

          def footer_attrs
            {
              data: (@attrs[:data] || {}).merge(slot: "panel-footer"),
              class: footer_classes
            }.merge(@attrs.except(:class, :data))
          end

          def footer_classes
            [ "panel__footer", @attrs[:class] ].compact.join(" ")
          end
      end
  end
end
