# frozen_string_literal: true

puts "Creating organizations..."

# Find users by email for organization ownership
admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")
alex_user = User.find_by!(email_address: "alex.chen@techcorp.com")
sarah_user = User.find_by!(email_address: "sarah.kim@startup.io")

Organization.find_or_create_by!(name: "FeedbackBin") do |org|
  org.subdomain = "feedbackbin"
  org.owner = admin_user
end

# Create a second organization to test different authorization scenarios
Organization.find_or_create_by!(name: "TechCorp") do |org|
  org.subdomain = "techcorp"
  org.owner = alex_user
end

# Create a third organization where Shane is a regular member (not admin)
Organization.find_or_create_by!(name: "InnovateLabs") do |org|
  org.subdomain = "innovatelabs"
  org.owner = sarah_user
end

puts "✅ Seeded organizations"
