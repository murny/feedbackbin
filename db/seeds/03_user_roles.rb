# frozen_string_literal: true

puts "Setting user roles..."

# Find users by known attributes
admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")
fake_user = User.find_by!(email_address: "fake_user@example.com")
jane_user = User.find_by!(email_address: "jane_doe@example.com")
alex_user = User.find_by!(email_address: "alex.chen@techcorp.com")
maya_user = User.find_by!(email_address: "maya.patel@designstudio.co")
carlos_user = User.find_by!(email_address: "carlos.rodriguez@freelance.dev")
sarah_user = User.find_by!(email_address: "sarah.kim@startup.io")
david_user = User.find_by!(email_address: "david.thompson@agency.com")

# Set user roles
admin_user.update!(role: :administrator)
maya_user.update!(role: :administrator)
sarah_user.update!(role: :administrator)

# These users remain as members (default role)
fake_user.update!(role: :member)
jane_user.update!(role: :member)
alex_user.update!(role: :member)
carlos_user.update!(role: :member)
david_user.update!(role: :member)

puts "✅ Seeded user roles"
