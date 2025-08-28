# frozen_string_literal: true

puts "Creating post statuses..."

# Find organizations by name
feedbackbin_org = Organization.find_by!(name: "FeedbackBin")
techcorp_org = Organization.find_by!(name: "TechCorp")
innovatelabs_org = Organization.find_by!(name: "InnovateLabs")

# FeedbackBin statuses
PostStatus.find_or_create_by!(name: "In Progress", organization: feedbackbin_org) do |status|
  status.color = "#FFA500"
  status.position = 1
end
PostStatus.find_or_create_by!(name: "Planned", organization: feedbackbin_org) do |status|
  status.color = "#FF0000"
  status.position = 2
end
PostStatus.find_or_create_by!(name: "Archived", organization: feedbackbin_org) do |status|
  status.color = "#000000"
  status.position = 3
end
PostStatus.find_or_create_by!(name: "Complete", organization: feedbackbin_org) do |status|
  status.color = "#008000"
  status.position = 4
end

# TechCorp statuses
PostStatus.find_or_create_by!(name: "Backlog", organization: techcorp_org) do |status|
  status.color = "#6B7280"
  status.position = 1
end
PostStatus.find_or_create_by!(name: "In Review", organization: techcorp_org) do |status|
  status.color = "#F59E0B"
  status.position = 2
end
PostStatus.find_or_create_by!(name: "Done", organization: techcorp_org) do |status|
  status.color = "#10B981"
  status.position = 3
end

# InnovateLabs statuses
PostStatus.find_or_create_by!(name: "Under Review", organization: innovatelabs_org) do |status|
  status.color = "#8B5CF6"
  status.position = 1
end
PostStatus.find_or_create_by!(name: "In Development", organization: innovatelabs_org) do |status|
  status.color = "#06B6D4"
  status.position = 2
end
PostStatus.find_or_create_by!(name: "Testing", organization: innovatelabs_org) do |status|
  status.color = "#F59E0B"
  status.position = 3
end
PostStatus.find_or_create_by!(name: "Deployed", organization: innovatelabs_org) do |status|
  status.color = "#10B981"
  status.position = 4
end
PostStatus.find_or_create_by!(name: "Rejected", organization: innovatelabs_org) do |status|
  status.color = "#EF4444"
  status.position = 5
end

puts "✅ Created #{PostStatus.count} post statuses across all organizations"
