# frozen_string_literal: true

puts "Creating organizations..."

admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")

organization = Organization.find_or_create_by!(name: "FeedbackBin") do |org|
  org.subdomain = "feedbackbin"
  org.default_post_status = PostStatus.ordered.first
  org.owner = admin_user
end

# Create system user for automated actions
puts "Creating system user..."
organization.system_user

puts "✅ Seeded organizations and system users"
