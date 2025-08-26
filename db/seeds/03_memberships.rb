# frozen_string_literal: true

puts "Creating memberships..."

# FeedbackBin memberships
Membership.find_or_create_by!(organization: $seed_organizations[:feedbackbin], user: $seed_users[:admin], role: :administrator)
Membership.find_or_create_by!(organization: $seed_organizations[:feedbackbin], user: $seed_users[:user], role: :member)
Membership.find_or_create_by!(organization: $seed_organizations[:feedbackbin], user: $seed_users[:user_two], role: :member)
Membership.find_or_create_by!(organization: $seed_organizations[:feedbackbin], user: $seed_users[:alex], role: :member)
Membership.find_or_create_by!(organization: $seed_organizations[:feedbackbin], user: $seed_users[:maya], role: :administrator)
Membership.find_or_create_by!(organization: $seed_organizations[:feedbackbin], user: $seed_users[:carlos], role: :member)
Membership.find_or_create_by!(organization: $seed_organizations[:feedbackbin], user: $seed_users[:sarah], role: :administrator)
Membership.find_or_create_by!(organization: $seed_organizations[:feedbackbin], user: $seed_users[:david], role: :member)

# TechCorp memberships
# Alex is the owner/admin
Membership.find_or_create_by!(organization: $seed_organizations[:techcorp], user: $seed_users[:alex], role: :administrator)
# Maya as another admin
Membership.find_or_create_by!(organization: $seed_organizations[:techcorp], user: $seed_users[:maya], role: :administrator)
# Regular members
Membership.find_or_create_by!(organization: $seed_organizations[:techcorp], user: $seed_users[:carlos], role: :member)
Membership.find_or_create_by!(organization: $seed_organizations[:techcorp], user: $seed_users[:david], role: :member)
# Note: Admin user (Shane) is NOT a member of this organization for testing authorization

# InnovateLabs memberships
# Sarah is the owner/admin
Membership.find_or_create_by!(organization: $seed_organizations[:innovatelabs], user: $seed_users[:sarah], role: :administrator)
# David as another admin
Membership.find_or_create_by!(organization: $seed_organizations[:innovatelabs], user: $seed_users[:david], role: :administrator)
# Regular members including Shane (admin user)
Membership.find_or_create_by!(organization: $seed_organizations[:innovatelabs], user: $seed_users[:admin], role: :member)
Membership.find_or_create_by!(organization: $seed_organizations[:innovatelabs], user: $seed_users[:user], role: :member)
Membership.find_or_create_by!(organization: $seed_organizations[:innovatelabs], user: $seed_users[:maya], role: :member)
Membership.find_or_create_by!(organization: $seed_organizations[:innovatelabs], user: $seed_users[:alex], role: :member)

# Store membership counts for display
memberships_count = {
  feedbackbin: Membership.where(organization: $seed_organizations[:feedbackbin]).count,
  techcorp: Membership.where(organization: $seed_organizations[:techcorp]).count,
  innovatelabs: Membership.where(organization: $seed_organizations[:innovatelabs]).count
}

puts "✅ Created memberships for organizations:"
puts "   - FeedbackBin: #{memberships_count[:feedbackbin]} members"
puts "   - TechCorp: #{memberships_count[:techcorp]} members"
puts "   - InnovateLabs: #{memberships_count[:innovatelabs]} members"