# frozen_string_literal: true

puts "Creating categories..."

category = Category.find_or_create_by!(name: "Customer Feedback", description: "Share your ideas and help us improve our product", organization: $seed_organization)

# Additional categories for variety
bug_reports = Category.find_or_create_by!(name: "Bug Reports", description: "Report issues and bugs you've encountered", organization: $seed_organization)
feature_requests = Category.find_or_create_by!(name: "Feature Requests", description: "Suggest new features and improvements", organization: $seed_organization)
ui_ux = Category.find_or_create_by!(name: "UI/UX Feedback", description: "Share feedback about the user interface and experience", organization: $seed_organization)

# Store categories for other seed files to access
$seed_categories = {
  customer_feedback: category,
  bug_reports: bug_reports,
  feature_requests: feature_requests,
  ui_ux: ui_ux
}

puts "✅ Created #{$seed_categories.count} categories"