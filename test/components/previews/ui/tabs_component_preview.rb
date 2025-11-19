# frozen_string_literal: true

module Ui
  # @label Tabs
  class TabsComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      render Ui::TabsComponent.new(
        items: [
          {
            label: "Account",
            value: "account",
            content: tag.div(class: "space-y-4") do
              tag.h3("Account Settings", class: "text-lg font-semibold") +
              tag.p("Make changes to your account here. Click save when you're done.", class: "text-sm text-muted-foreground")
            end
          },
          {
            label: "Password",
            value: "password",
            content: tag.div(class: "space-y-4") do
              tag.h3("Password Settings", class: "text-lg font-semibold") +
              tag.p("Change your password here. After saving, you'll be logged out.", class: "text-sm text-muted-foreground")
            end
          },
          {
            label: "Settings",
            value: "settings",
            content: tag.div(class: "space-y-4") do
              tag.h3("General Settings", class: "text-lg font-semibold") +
              tag.p("Manage your account settings and preferences.", class: "text-sm text-muted-foreground")
            end
          }
        ]
      )
    end

    # @label With Icons
    def with_icons
      render Ui::TabsComponent.new(
        items: [
          {
            label: "Profile",
            value: "profile",
            icon: "user",
            content: tag.div(class: "text-sm") do
              tag.p("Your profile information and public details.")
            end
          },
          {
            label: "Billing",
            value: "billing",
            icon: "credit-card",
            content: tag.div(class: "text-sm") do
              tag.p("Manage your billing and subscription settings.")
            end
          },
          {
            label: "Notifications",
            value: "notifications",
            icon: "bell",
            content: tag.div(class: "text-sm") do
              tag.p("Configure your notification preferences.")
            end
          }
        ]
      )
    end

    # @label Start on Second Tab
    def second_tab
      render Ui::TabsComponent.new(
        items: [
          { label: "Tab 1", value: "tab1", content: tag.div("First tab content", class: "text-sm") },
          { label: "Tab 2", value: "tab2", content: tag.div("Second tab content (initially visible)", class: "text-sm") },
          { label: "Tab 3", value: "tab3", content: tag.div("Third tab content", class: "text-sm") }
        ],
        index_value: 1
      )
    end

    # @label With Disabled Tab
    def with_disabled
      render Ui::TabsComponent.new(
        items: [
          {
            label: "Available",
            value: "available",
            content: tag.div("This tab is accessible", class: "text-sm")
          },
          {
            label: "Disabled",
            value: "disabled",
            disabled: true,
            content: tag.div("Cannot access this", class: "text-sm")
          },
          {
            label: "Active",
            value: "active",
            content: tag.div("Another accessible tab", class: "text-sm")
          }
        ]
      )
    end

    # @label Many Tabs
    def many_tabs
      render Ui::TabsComponent.new(
        items: [
          { label: "Overview", value: "overview", icon: "home", content: tag.div("Overview content", class: "text-sm") },
          { label: "Analytics", value: "analytics", icon: "bar-chart", content: tag.div("Analytics content", class: "text-sm") },
          { label: "Reports", value: "reports", icon: "file-text", content: tag.div("Reports content", class: "text-sm") },
          { label: "Notifications", value: "notifications", icon: "bell", content: tag.div("Notifications content", class: "text-sm") },
          { label: "Settings", value: "settings", icon: "settings", content: tag.div("Settings content", class: "text-sm") }
        ]
      )
    end

    # @label With Rich Content
    def with_rich_content
      render Ui::TabsComponent.new(
        items: [
          {
            label: "Overview",
            value: "overview",
            icon: "layout-dashboard",
            content: tag.div(class: "space-y-4") do
              tag.div(class: "grid grid-cols-3 gap-4") do
                3.times.map do |i|
                  tag.div(class: "rounded-lg border p-4") do
                    tag.div("Metric #{i + 1}", class: "text-sm font-medium text-muted-foreground") +
                    tag.div("#{(i + 1) * 100}", class: "text-2xl font-bold")
                  end
                end.join.html_safe
              end
            end
          },
          {
            label: "Details",
            value: "details",
            icon: "list",
            content: tag.div(class: "space-y-2") do
              tag.ul(class: "space-y-2") do
                [ "Item 1", "Item 2", "Item 3" ].map do |item|
                  tag.li(item, class: "text-sm")
                end.join.html_safe
              end
            end
          }
        ]
      )
    end
  end
end
