# frozen_string_literal: true

puts "Creating categories..."

# Find organizations by name
feedbackbin_org = Organization.find_by!(name: "FeedbackBin")
techcorp_org = Organization.find_by!(name: "TechCorp")
innovatelabs_org = Organization.find_by!(name: "InnovateLabs")

# FeedbackBin categories
ApplicationRecord.with_tenant(feedbackbin_org.subdomain) do
  Category.find_or_create_by!(name: "Customer Feedback") do |category|
    category.description = "Share your ideas and help us improve our product"
  end
  Category.find_or_create_by!(name: "Bug Reports") do |category|
    category.description = "Report issues and bugs you've encountered"
  end
  Category.find_or_create_by!(name: "Feature Requests") do |category|
    category.description = "Suggest new features and improvements"
  end
  Category.find_or_create_by!(name: "UI/UX Feedback") do |category|
    category.description = "Share feedback about the user interface and experience"
  end
end

# TechCorp categories
ApplicationRecord.with_tenant(techcorp_org.subdomain) do
  Category.find_or_create_by!(name: "Product") do |category|
    category.description = "Product-related feedback and suggestions"
  end
  Category.find_or_create_by!(name: "Engineering") do |category|
    category.description = "Technical feedback and bug reports"
  end
end

# InnovateLabs categories
ApplicationRecord.with_tenant(innovatelabs_org.subdomain) do
  Category.find_or_create_by!(name: "Mobile App") do |category|
    category.description = "Feedback on our mobile application experience"
  end
  Category.find_or_create_by!(name: "Platform") do |category|
    category.description = "Core platform features and infrastructure"
  end
  Category.find_or_create_by!(name: "Integrations") do |category|
    category.description = "Third-party integrations and API requests"
  end
end

puts "✅ Seeded categories"
