# frozen_string_literal: true

puts "Creating memberships..."

# Find organizations and users by known attributes
feedbackbin_org = Organization.find_by!(name: "FeedbackBin")
techcorp_org = Organization.find_by!(name: "TechCorp")
innovatelabs_org = Organization.find_by!(name: "InnovateLabs")

admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")
fake_user = User.find_by!(email_address: "fake_user@example.com")
jane_user = User.find_by!(email_address: "jane_doe@example.com")
alex_user = User.find_by!(email_address: "alex.chen@techcorp.com")
maya_user = User.find_by!(email_address: "maya.patel@designstudio.co")
carlos_user = User.find_by!(email_address: "carlos.rodriguez@freelance.dev")
sarah_user = User.find_by!(email_address: "sarah.kim@startup.io")
david_user = User.find_by!(email_address: "david.thompson@agency.com")

# FeedbackBin memberships
Membership.find_or_create_by!(organization: feedbackbin_org, user: admin_user) do |membership|
  membership.role = :administrator
end
Membership.find_or_create_by!(organization: feedbackbin_org, user: fake_user) do |membership|
  membership.role = :member
end
Membership.find_or_create_by!(organization: feedbackbin_org, user: jane_user) do |membership|
  membership.role = :member
end
Membership.find_or_create_by!(organization: feedbackbin_org, user: alex_user) do |membership|
  membership.role = :member
end
Membership.find_or_create_by!(organization: feedbackbin_org, user: maya_user) do |membership|
  membership.role = :administrator
end
Membership.find_or_create_by!(organization: feedbackbin_org, user: carlos_user) do |membership|
  membership.role = :member
end
Membership.find_or_create_by!(organization: feedbackbin_org, user: sarah_user) do |membership|
  membership.role = :administrator
end
Membership.find_or_create_by!(organization: feedbackbin_org, user: david_user) do |membership|
  membership.role = :member
end

# TechCorp memberships
# Alex is the owner/admin
Membership.find_or_create_by!(organization: techcorp_org, user: alex_user) do |membership|
  membership.role = :administrator
end
# Maya as another admin
Membership.find_or_create_by!(organization: techcorp_org, user: maya_user) do |membership|
  membership.role = :administrator
end
# Regular members
Membership.find_or_create_by!(organization: techcorp_org, user: carlos_user) do |membership|
  membership.role = :member
end
Membership.find_or_create_by!(organization: techcorp_org, user: david_user) do |membership|
  membership.role = :member
end
# Note: Admin user (Shane) is NOT a member of this organization for testing authorization

# InnovateLabs memberships
# Sarah is the owner/admin
Membership.find_or_create_by!(organization: innovatelabs_org, user: sarah_user) do |membership|
  membership.role = :administrator
end
# David as another admin
Membership.find_or_create_by!(organization: innovatelabs_org, user: david_user) do |membership|
  membership.role = :administrator
end
# Regular members including Shane (admin user)
Membership.find_or_create_by!(organization: innovatelabs_org, user: admin_user) do |membership|
  membership.role = :member
end
Membership.find_or_create_by!(organization: innovatelabs_org, user: fake_user) do |membership|
  membership.role = :member
end
Membership.find_or_create_by!(organization: innovatelabs_org, user: maya_user) do |membership|
  membership.role = :member
end
Membership.find_or_create_by!(organization: innovatelabs_org, user: alex_user) do |membership|
  membership.role = :member
end

puts "✅ Created #{Membership.count} memberships across all organizations"
