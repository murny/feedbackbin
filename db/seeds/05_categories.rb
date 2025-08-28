# frozen_string_literal: true

puts "Creating categories..."

# Find organizations by name
feedbackbin_org = Organization.find_by!(name: "FeedbackBin")
techcorp_org = Organization.find_by!(name: "TechCorp")
innovatelabs_org = Organization.find_by!(name: "InnovateLabs")

# FeedbackBin categories
Category.find_or_create_by!(name: "Customer Feedback", organization: feedbackbin_org) do |category|
  category.description = "Share your ideas and help us improve our product"
end
Category.find_or_create_by!(name: "Bug Reports", organization: feedbackbin_org) do |category|
  category.description = "Report issues and bugs you've encountered"
end
Category.find_or_create_by!(name: "Feature Requests", organization: feedbackbin_org) do |category|
  category.description = "Suggest new features and improvements"
end
Category.find_or_create_by!(name: "UI/UX Feedback", organization: feedbackbin_org) do |category|
  category.description = "Share feedback about the user interface and experience"
end

# TechCorp categories
Category.find_or_create_by!(name: "Product", organization: techcorp_org) do |category|
  category.description = "Product-related feedback and suggestions"
end
Category.find_or_create_by!(name: "Engineering", organization: techcorp_org) do |category|
  category.description = "Technical feedback and bug reports"
end

# InnovateLabs categories
Category.find_or_create_by!(name: "Mobile App", organization: innovatelabs_org) do |category|
  category.description = "Feedback on our mobile application experience"
end
Category.find_or_create_by!(name: "Platform", organization: innovatelabs_org) do |category|
  category.description = "Core platform features and infrastructure"
end
Category.find_or_create_by!(name: "Integrations", organization: innovatelabs_org) do |category|
  category.description = "Third-party integrations and API requests"
end

puts "✅ Created #{Category.count} categories across all organizations"
