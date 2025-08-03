# frozen_string_literal: true

puts "Creating organizations, statuses, and memberships..."

organization = Organization.find_or_create_by!(name: "FeedbackBin", owner: $seed_users[:admin])

PostStatus.find_or_create_by!(name: "In Progress", color: "#FFA500", position: 1, organization: organization)
PostStatus.find_or_create_by!(name: "Planned", color: "#FF0000", position: 2, organization: organization)
PostStatus.find_or_create_by!(name: "Archived", color: "#000000", position: 3, organization: organization)
PostStatus.find_or_create_by!(name: "Complete", color: "#008000", position: 4, organization: organization)

Membership.find_or_create_by!(organization: organization, user: $seed_users[:admin], role: :administrator)
Membership.find_or_create_by!(organization: organization, user: $seed_users[:user], role: :member)
Membership.find_or_create_by!(organization: organization, user: $seed_users[:user_two], role: :member)
Membership.find_or_create_by!(organization: organization, user: $seed_users[:alex], role: :member)
Membership.find_or_create_by!(organization: organization, user: $seed_users[:maya], role: :administrator)
Membership.find_or_create_by!(organization: organization, user: $seed_users[:carlos], role: :member)
Membership.find_or_create_by!(organization: organization, user: $seed_users[:sarah], role: :administrator)
Membership.find_or_create_by!(organization: organization, user: $seed_users[:david], role: :member)

# Store organization for other seed files to access
$seed_organization = organization

puts "✅ Created organization with #{PostStatus.where(organization: organization).count} statuses and #{Membership.where(organization: organization).count} memberships"
