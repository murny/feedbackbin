# frozen_string_literal: true

puts "Creating organizations..."

organization = Organization.find_or_create_by!(name: "FeedbackBin", owner: $seed_users[:admin])

# Create a second organization to test different authorization scenarios
test_org = Organization.find_or_create_by!(name: "TechCorp", owner: $seed_users[:alex])

# Create a third organization where Shane is a regular member (not admin)
startup_org = Organization.find_or_create_by!(name: "InnovateLabs", owner: $seed_users[:sarah])

# Store organizations for other seed files to access
$seed_organizations = {
  feedbackbin: organization,
  techcorp: test_org,
  innovatelabs: startup_org
}

puts "✅ Created #{$seed_organizations.count} organizations"