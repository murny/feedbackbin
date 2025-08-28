# frozen_string_literal: true

puts "Creating organizations..."

# Find users by email for organization ownership
admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")
alex_user = User.find_by!(email_address: "alex.chen@techcorp.com")
sarah_user = User.find_by!(email_address: "sarah.kim@startup.io")

Organization.find_or_create_by!(name: "FeedbackBin", owner: admin_user)

# Create a second organization to test different authorization scenarios
Organization.find_or_create_by!(name: "TechCorp", owner: alex_user)

# Create a third organization where Shane is a regular member (not admin)
Organization.find_or_create_by!(name: "InnovateLabs", owner: sarah_user)

puts "✅ Created #{Organization.count} organizations"
