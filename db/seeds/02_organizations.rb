# frozen_string_literal: true

puts "Creating organizations..."

# Find users by email for organization ownership
admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")

Organization.find_or_create_by!(name: "FeedbackBin") do |org|
  org.owner = admin_user
  org.subdomain = "feedbackbin"
end

puts "✅ Seeded organizations"
