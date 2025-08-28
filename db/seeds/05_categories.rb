# frozen_string_literal: true

puts "Creating categories..."

# Find organizations by name
feedbackbin_org = Organization.find_by!(name: "FeedbackBin")
techcorp_org = Organization.find_by!(name: "TechCorp")
innovatelabs_org = Organization.find_by!(name: "InnovateLabs")

# FeedbackBin categories
Category.find_or_create_by!(name: "Customer Feedback", description: "Share your ideas and help us improve our product", organization: feedbackbin_org)
Category.find_or_create_by!(name: "Bug Reports", description: "Report issues and bugs you've encountered", organization: feedbackbin_org)
Category.find_or_create_by!(name: "Feature Requests", description: "Suggest new features and improvements", organization: feedbackbin_org)
Category.find_or_create_by!(name: "UI/UX Feedback", description: "Share feedback about the user interface and experience", organization: feedbackbin_org)

# TechCorp categories
Category.find_or_create_by!(name: "Product", description: "Product-related feedback and suggestions", organization: techcorp_org)
Category.find_or_create_by!(name: "Engineering", description: "Technical feedback and bug reports", organization: techcorp_org)

# InnovateLabs categories
Category.find_or_create_by!(name: "Mobile App", description: "Feedback on our mobile application experience", organization: innovatelabs_org)
Category.find_or_create_by!(name: "Platform", description: "Core platform features and infrastructure", organization: innovatelabs_org)
Category.find_or_create_by!(name: "Integrations", description: "Third-party integrations and API requests", organization: innovatelabs_org)

puts "✅ Created categories for organizations"
