# frozen_string_literal: true

module Ui
  class CardComponent < BaseComponent
    renders_one :header, lambda { |title: nil, description: nil, **attrs|
      HeaderComponent.new(title: title, description: description, **attrs)
    }
    renders_one :body, lambda { |**attrs|
      BodyComponent.new(**attrs)
    }
    renders_one :footer, lambda { |**attrs|
      FooterComponent.new(**attrs)
    }

    def initialize(**attrs)
      @attrs = attrs
    end

    def call
      tag.div(**card_attrs) do
        safe_join([ header, body, footer ].compact)
      end
    end

    private

      def card_attrs
        {
          data: { slot: "card" }.merge(@attrs[:data] || {}),
          class: card_classes
        }.merge(@attrs.except(:class, :data))
      end

      def card_classes
        tw_merge(base_classes, @attrs[:class])
      end

      def base_classes
        "bg-card text-card-foreground flex flex-col gap-6 rounded-xl border py-6 shadow-sm"
      end

      # Header subcomponent
      class HeaderComponent < BaseComponent
        def initialize(title: nil, description: nil, **attrs)
          @title = title
          @description = description
          @attrs = attrs
        end

        def call
          tag.div(**header_attrs) do
            if content.present?
              # Has action content from block
              text_content = render_text_content
              if text_content.present?
                safe_join([
                  tag.div { text_content },
                  tag.div(data: { slot: "card-action" }) { content }
                ])
              else
                # Only action, no title/description
                tag.div(data: { slot: "card-action" }) { content }
              end
            else
              # No action
              render_text_content
            end
          end
        end

        private

          def header_attrs
            {
              data: { slot: "card-header" }.merge(@attrs[:data] || {}),
              class: header_classes
            }.merge(@attrs.except(:class, :data))
          end

          def header_classes
            tw_merge(base_header_classes, @attrs[:class])
          end

          def base_header_classes
            [
              "@container/card-header grid auto-rows-min grid-rows-[auto_auto] items-start gap-1.5 px-6",
              "has-[data-slot=card-action]:grid-cols-[1fr_auto]",
              "[.border-b_&]:pb-6"
            ].join(" ")
          end

          def render_text_content
            parts = [ render_title, render_description ].compact
            return nil if parts.empty?

            safe_join(parts)
          end

          def render_title
            return nil unless @title.present?

            tag.div(@title, data: { slot: "card-title" }, class: "leading-none font-semibold")
          end

          def render_description
            return nil unless @description.present?

            tag.div(@description, data: { slot: "card-description" }, class: "text-muted-foreground text-sm")
          end
      end

      # Body subcomponent
      class BodyComponent < BaseComponent
        def initialize(**attrs)
          @attrs = attrs
        end

        def call
          tag.div(**body_attrs) { content }
        end

        private

          def body_attrs
            {
              data: { slot: "card-content" }.merge(@attrs[:data] || {}),
              class: body_classes
            }.merge(@attrs.except(:class, :data))
          end

          def body_classes
            tw_merge("px-6 text-sm", @attrs[:class])
          end
      end

      # Footer subcomponent
      class FooterComponent < BaseComponent
        def initialize(**attrs)
          @attrs = attrs
        end

        def call
          tag.div(**footer_attrs) { content }
        end

        private

          def footer_attrs
            {
              data: { slot: "card-footer" }.merge(@attrs[:data] || {}),
              class: footer_classes
            }.merge(@attrs.except(:class, :data))
          end

          def footer_classes
            tw_merge("flex items-center px-6 text-sm", @attrs[:class])
          end
      end
  end
end
