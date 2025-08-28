# frozen_string_literal: true

puts "Creating post statuses..."

# Find organizations by name
feedbackbin_org = Organization.find_by!(name: "FeedbackBin")
techcorp_org = Organization.find_by!(name: "TechCorp")
innovatelabs_org = Organization.find_by!(name: "InnovateLabs")

# FeedbackBin statuses
PostStatus.find_or_create_by!(name: "In Progress", color: "#FFA500", position: 1, organization: feedbackbin_org)
PostStatus.find_or_create_by!(name: "Planned", color: "#FF0000", position: 2, organization: feedbackbin_org)
PostStatus.find_or_create_by!(name: "Archived", color: "#000000", position: 3, organization: feedbackbin_org)
PostStatus.find_or_create_by!(name: "Complete", color: "#008000", position: 4, organization: feedbackbin_org)

# TechCorp statuses
PostStatus.find_or_create_by!(name: "Backlog", color: "#6B7280", position: 1, organization: techcorp_org)
PostStatus.find_or_create_by!(name: "In Review", color: "#F59E0B", position: 2, organization: techcorp_org)
PostStatus.find_or_create_by!(name: "Done", color: "#10B981", position: 3, organization: techcorp_org)

# InnovateLabs statuses
PostStatus.find_or_create_by!(name: "Under Review", color: "#8B5CF6", position: 1, organization: innovatelabs_org)
PostStatus.find_or_create_by!(name: "In Development", color: "#06B6D4", position: 2, organization: innovatelabs_org)
PostStatus.find_or_create_by!(name: "Testing", color: "#F59E0B", position: 3, organization: innovatelabs_org)
PostStatus.find_or_create_by!(name: "Deployed", color: "#10B981", position: 4, organization: innovatelabs_org)
PostStatus.find_or_create_by!(name: "Rejected", color: "#EF4444", position: 5, organization: innovatelabs_org)

puts "✅ Created post statuses for organizations"
