# frozen_string_literal: true

puts "Creating categories..."

# FeedbackBin categories
feedbackbin_customer_feedback = Category.find_or_create_by!(name: "Customer Feedback", description: "Share your ideas and help us improve our product", organization: $seed_organizations[:feedbackbin])
feedbackbin_bug_reports = Category.find_or_create_by!(name: "Bug Reports", description: "Report issues and bugs you've encountered", organization: $seed_organizations[:feedbackbin])
feedbackbin_feature_requests = Category.find_or_create_by!(name: "Feature Requests", description: "Suggest new features and improvements", organization: $seed_organizations[:feedbackbin])
feedbackbin_ui_ux = Category.find_or_create_by!(name: "UI/UX Feedback", description: "Share feedback about the user interface and experience", organization: $seed_organizations[:feedbackbin])

# TechCorp categories
techcorp_product = Category.find_or_create_by!(name: "Product", description: "Product-related feedback and suggestions", organization: $seed_organizations[:techcorp])
techcorp_engineering = Category.find_or_create_by!(name: "Engineering", description: "Technical feedback and bug reports", organization: $seed_organizations[:techcorp])

# InnovateLabs categories
innovatelabs_mobile = Category.find_or_create_by!(name: "Mobile App", description: "Feedback on our mobile application experience", organization: $seed_organizations[:innovatelabs])
innovatelabs_platform = Category.find_or_create_by!(name: "Platform", description: "Core platform features and infrastructure", organization: $seed_organizations[:innovatelabs])
innovatelabs_integrations = Category.find_or_create_by!(name: "Integrations", description: "Third-party integrations and API requests", organization: $seed_organizations[:innovatelabs])

# Store categories for posts seed file
$seed_categories = {
  feedbackbin: {
    customer_feedback: feedbackbin_customer_feedback,
    bug_reports: feedbackbin_bug_reports,
    feature_requests: feedbackbin_feature_requests,
    ui_ux: feedbackbin_ui_ux
  },
  techcorp: {
    product: techcorp_product,
    engineering: techcorp_engineering
  },
  innovatelabs: {
    mobile: innovatelabs_mobile,
    platform: innovatelabs_platform,
    integrations: innovatelabs_integrations
  }
}

puts "✅ Created categories for organizations:"
puts "   - FeedbackBin: #{$seed_categories[:feedbackbin].count} categories"
puts "   - TechCorp: #{$seed_categories[:techcorp].count} categories"
puts "   - InnovateLabs: #{$seed_categories[:innovatelabs].count} categories"