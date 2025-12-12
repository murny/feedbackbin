# frozen_string_literal: true

puts "Creating statuses..."

Status.find_or_create_by!(name: "Open") do |status|
  status.color = "#3b82f6"  # Blue
  status.position = 1
  status.show_on_idea = true
  status.show_on_roadmap = false
end

Status.find_or_create_by!(name: "Planned") do |status|
  status.color = "#8b5cf6"  # Purple
  status.position = 2
  status.show_on_idea = true
  status.show_on_roadmap = true
end

Status.find_or_create_by!(name: "In Progress") do |status|
  status.color = "#f59e0b"  # Orange
  status.position = 3
  status.show_on_idea = true
  status.show_on_roadmap = true
end

Status.find_or_create_by!(name: "Complete") do |status|
  status.color = "#10b981"  # Green
  status.position = 4
  status.show_on_idea = false
  status.show_on_roadmap = true
end

Status.find_or_create_by!(name: "Closed") do |status|
  status.color = "#ef4444"  # Red
  status.position = 5
  status.show_on_idea = false
  status.show_on_roadmap = false
end

puts "✅ Seeded statuses"
