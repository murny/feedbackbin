# frozen_string_literal: true

module Ui
  # @label Card
  class CardComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      render Ui::CardComponent.new do |c|
        c.with_header(title: "Card Title", description: "Card description")
        c.with_body do
          tag.p("This is the card content. It can contain any HTML elements.")
        end
      end
    end

    # @label With Header Action
    def with_header_action
      render Ui::CardComponent.new do |c|
        c.with_header(title: "Notifications", description: "You have 3 unread messages.") do
          render Ui::ButtonComponent.new(variant: :outline, size: :sm) { "Mark all as read" }
        end
        c.with_body do
          tag.div(class: "space-y-4") do
            safe_join([
              tag.p("Message 1: New feature release", class: "text-sm"),
              tag.p("Message 2: System update available", class: "text-sm"),
              tag.p("Message 3: Welcome to the platform", class: "text-sm")
            ])
          end
        end
      end
    end

    # @label With Footer
    def with_footer
      render Ui::CardComponent.new do |c|
        c.with_header(title: "Create project", description: "Deploy your new project in one-click.")
        c.with_body do
          tag.div(class: "space-y-4") do
            safe_join([
              tag.div(class: "space-y-2") do
                safe_join([
                  tag.label("Name", class: "text-sm font-medium"),
                  tag.input(type: "text", placeholder: "Project name", class: "w-full rounded-md border px-3 py-2 text-sm")
                ])
              end,
              tag.div(class: "space-y-2") do
                safe_join([
                  tag.label("Framework", class: "text-sm font-medium"),
                  tag.select(class: "w-full rounded-md border px-3 py-2 text-sm") do
                    safe_join([
                      tag.option("Next.js"),
                      tag.option("SvelteKit"),
                      tag.option("Nuxt.js")
                    ])
                  end
                ])
              end
            ])
          end
        end
        c.with_footer do
          tag.div(class: "flex gap-2") do
            safe_join([
              render(Ui::ButtonComponent.new(variant: :outline)) { "Cancel" },
              render(Ui::ButtonComponent.new(variant: :default)) { "Deploy" }
            ])
          end
        end
      end
    end

    # @label Simple - Title Only
    def simple_title_only
      render Ui::CardComponent.new do |c|
        c.with_header(title: "Simple Card")
        c.with_body do
          tag.p("Just a title and some content.", class: "text-sm")
        end
      end
    end

    # @label Content Only
    def content_only
      render Ui::CardComponent.new do |c|
        c.with_body do
          tag.div(class: "p-6 text-center") do
            safe_join([
              tag.h3("No Header", class: "text-lg font-semibold mb-2"),
              tag.p("This card has no header, just content.", class: "text-sm text-muted-foreground")
            ])
          end
        end
      end
    end

    # @label With Border Separators
    # Shows how to use .border-b and .border-t classes
    def with_border_separators
      render Ui::CardComponent.new(class: "border-b") do |c|
        c.with_header(title: "Account Settings", description: "Manage your account preferences")
        c.with_body do
          tag.div(class: "space-y-3") do
            safe_join([
              tag.div(class: "flex items-center justify-between") do
                safe_join([
                  tag.span("Email notifications", class: "text-sm"),
                  tag.input(type: "checkbox", checked: true)
                ])
              end,
              tag.div(class: "flex items-center justify-between") do
                safe_join([
                  tag.span("SMS notifications", class: "text-sm"),
                  tag.input(type: "checkbox")
                ])
              end
            ])
          end
        end
        c.with_footer(class: "border-t") do
          render(Ui::ButtonComponent.new(variant: :default, size: :sm)) { "Save changes" }
        end
      end
    end

    # @label Product Card Example
    def product_card
      render_with_template
    end

    # @label Multiple Cards Grid
    def multiple_cards
      render_with_template
    end

    # @label Nested Content
    def nested_content
      render Ui::CardComponent.new do |c|
        c.with_header(title: "Dashboard", description: "Overview of your metrics")
        c.with_body do
          tag.div(class: "grid grid-cols-2 gap-4") do
            safe_join([
              tag.div(class: "rounded-lg bg-muted p-4") do
                safe_join([
                  tag.div("Users", class: "text-sm text-muted-foreground"),
                  tag.div("1,234", class: "text-2xl font-bold")
                ])
              end,
              tag.div(class: "rounded-lg bg-muted p-4") do
                safe_join([
                  tag.div("Revenue", class: "text-sm text-muted-foreground"),
                  tag.div("$12,345", class: "text-2xl font-bold")
                ])
              end
            ])
          end
        end
      end
    end
  end
end
