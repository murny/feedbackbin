# frozen_string_literal: true

create_tenant "FeedbackBin"

shane = find_or_create_user "Shane Murnaghan", "shane@example.com"
jane = find_or_create_user "Jane Doe", "jane@example.com"
john    = find_or_create_user "John Smith", "john@example.com"
eric = find_or_create_user "Eric Johnson", "eric@example.com"

login_as shane

create_board("Customer Feedback").tap do |customer_feedback|
  create_idea("Could you please add dark mode",
    description: "I would love to see dark mode on this site, please give support for it",
    board: customer_feedback)


  create_idea("Mobile app support",
    description: "As a UX designer, I'd love to see a dedicated mobile app. The responsive web version is good, but a native app would provide better user engagement and push notifications for important updates. This would be especially valuable for teams that need to stay on top of feedback while on the go.",
    board: customer_feedback)
end
