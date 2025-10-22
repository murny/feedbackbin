# frozen_string_literal: true

puts "Creating categories..."

# FeedbackBin categories
Category.find_or_create_by!(name: "Customer Feedback") do |category|
  category.description = "Share your ideas and help us improve our product"
  category.color = "#3b82f6"  # Blue
end

Category.find_or_create_by!(name: "Bug Reports") do |category|
  category.description = "Report issues and bugs you've encountered"
  category.color = "#ef4444"  # Red
end

Category.find_or_create_by!(name: "Feature Requests") do |category|
  category.description = "Suggest new features and improvements"
  category.color = "#10b981"  # Green
end

Category.find_or_create_by!(name: "UI/UX Feedback") do |category|
  category.description = "Share feedback about the user interface and experience"
  category.color = "#f59e0b"  # Orange
end

puts "✅ Seeded categories"
