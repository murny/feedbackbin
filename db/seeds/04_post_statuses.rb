# frozen_string_literal: true

puts "Creating post statuses..."

# Default statuses for FeedbackBin
# Note: First status by position is always the default for new posts

PostStatus.find_or_create_by!(name: "Open") do |status|
  status.color = "#3b82f6"  # Blue - default/initial state
  status.position = 1        # Default status (first by position)
end

PostStatus.find_or_create_by!(name: "Planned") do |status|
  status.color = "#8b5cf6"  # Purple - on roadmap
  status.position = 2
end

PostStatus.find_or_create_by!(name: "In Progress") do |status|
  status.color = "#f59e0b"  # Orange - actively working
  status.position = 3
end

PostStatus.find_or_create_by!(name: "Complete") do |status|
  status.color = "#10b981"  # Green - done/shipped
  status.position = 4
end

PostStatus.find_or_create_by!(name: "Closed") do |status|
  status.color = "#6b7280"  # Gray - rejected/won't do/archived
  status.position = 5
end

puts "✅ Seeded post statuses"
