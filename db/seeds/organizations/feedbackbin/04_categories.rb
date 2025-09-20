# frozen_string_literal: true

puts "Creating categories for FeedbackBin tenant..."

ApplicationRecord.with_tenant("feedbackbin") do
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

puts "✅ Seeded categories for FeedbackBin tenant"