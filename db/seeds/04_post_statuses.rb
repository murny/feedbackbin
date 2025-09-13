# frozen_string_literal: true

puts "Creating post statuses..."

# Find organizations by name
feedbackbin_org = Organization.find_by!(name: "FeedbackBin")
techcorp_org = Organization.find_by!(name: "TechCorp")
innovatelabs_org = Organization.find_by!(name: "InnovateLabs")

# FeedbackBin statuses
ApplicationRecord.with_tenant(feedbackbin_org.subdomain) do
  PostStatus.find_or_create_by!(name: "In Progress") do |status|
    status.color = "#FFA500"
    status.position = 1
  end
  PostStatus.find_or_create_by!(name: "Planned") do |status|
    status.color = "#FF0000"
    status.position = 2
  end
  PostStatus.find_or_create_by!(name: "Archived") do |status|
    status.color = "#000000"
    status.position = 3
  end
  PostStatus.find_or_create_by!(name: "Complete") do |status|
    status.color = "#008000"
    status.position = 4
  end
end

# TechCorp statuses
ApplicationRecord.with_tenant(techcorp_org.subdomain) do
  PostStatus.find_or_create_by!(name: "Backlog") do |status|
    status.color = "#6B7280"
    status.position = 1
  end
  PostStatus.find_or_create_by!(name: "In Review") do |status|
    status.color = "#F59E0B"
    status.position = 2
  end
  PostStatus.find_or_create_by!(name: "Done") do |status|
    status.color = "#10B981"
    status.position = 3
  end
end

# InnovateLabs statuses
ApplicationRecord.with_tenant(innovatelabs_org.subdomain) do
  PostStatus.find_or_create_by!(name: "Under Review") do |status|
    status.color = "#8B5CF6"
    status.position = 1
  end
  PostStatus.find_or_create_by!(name: "In Development") do |status|
    status.color = "#06B6D4"
    status.position = 2
  end
  PostStatus.find_or_create_by!(name: "Testing") do |status|
    status.color = "#F59E0B"
    status.position = 3
  end
  PostStatus.find_or_create_by!(name: "Deployed") do |status|
    status.color = "#10B981"
    status.position = 4
  end
  PostStatus.find_or_create_by!(name: "Rejected") do |status|
    status.color = "#EF4444"
    status.position = 5
  end
end

puts "✅ Seeded post statuses"
