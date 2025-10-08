# frozen_string_literal: true

puts "Creating post statuses..."

# Create statuses
PostStatus.find_or_create_by!(name: "Open") do |status|
  status.color = "#3b82f6"  # Blue
  status.position = 1
end

PostStatus.find_or_create_by!(name: "Planned") do |status|
  status.color = "#8b5cf6"  # Purple
  status.position = 2
end

PostStatus.find_or_create_by!(name: "In Progress") do |status|
  status.color = "#f59e0b"  # Orange
  status.position = 3
end

PostStatus.find_or_create_by!(name: "Complete") do |status|
  status.color = "#10b981"  # Green
  status.position = 4
end

PostStatus.find_or_create_by!(name: "Closed") do |status|
  status.color = "#ef4444"  # Red
  status.position = 5
end

puts "✅ Seeded post statuses"
