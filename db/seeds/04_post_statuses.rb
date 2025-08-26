# frozen_string_literal: true

puts "Creating post statuses..."

# FeedbackBin statuses
PostStatus.find_or_create_by!(name: "In Progress", color: "#FFA500", position: 1, organization: $seed_organizations[:feedbackbin])
PostStatus.find_or_create_by!(name: "Planned", color: "#FF0000", position: 2, organization: $seed_organizations[:feedbackbin])
PostStatus.find_or_create_by!(name: "Archived", color: "#000000", position: 3, organization: $seed_organizations[:feedbackbin])
PostStatus.find_or_create_by!(name: "Complete", color: "#008000", position: 4, organization: $seed_organizations[:feedbackbin])

# TechCorp statuses
PostStatus.find_or_create_by!(name: "Backlog", color: "#6B7280", position: 1, organization: $seed_organizations[:techcorp])
PostStatus.find_or_create_by!(name: "In Review", color: "#F59E0B", position: 2, organization: $seed_organizations[:techcorp])
PostStatus.find_or_create_by!(name: "Done", color: "#10B981", position: 3, organization: $seed_organizations[:techcorp])

# InnovateLabs statuses
PostStatus.find_or_create_by!(name: "Under Review", color: "#8B5CF6", position: 1, organization: $seed_organizations[:innovatelabs])
PostStatus.find_or_create_by!(name: "In Development", color: "#06B6D4", position: 2, organization: $seed_organizations[:innovatelabs])
PostStatus.find_or_create_by!(name: "Testing", color: "#F59E0B", position: 3, organization: $seed_organizations[:innovatelabs])
PostStatus.find_or_create_by!(name: "Deployed", color: "#10B981", position: 4, organization: $seed_organizations[:innovatelabs])
PostStatus.find_or_create_by!(name: "Rejected", color: "#EF4444", position: 5, organization: $seed_organizations[:innovatelabs])

# Count statuses per organization
statuses_count = {
  feedbackbin: PostStatus.where(organization: $seed_organizations[:feedbackbin]).count,
  techcorp: PostStatus.where(organization: $seed_organizations[:techcorp]).count,
  innovatelabs: PostStatus.where(organization: $seed_organizations[:innovatelabs]).count
}

puts "✅ Created post statuses for organizations:"
puts "   - FeedbackBin: #{statuses_count[:feedbackbin]} statuses"
puts "   - TechCorp: #{statuses_count[:techcorp]} statuses"
puts "   - InnovateLabs: #{statuses_count[:innovatelabs]} statuses"