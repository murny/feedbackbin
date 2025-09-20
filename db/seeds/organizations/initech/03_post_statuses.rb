# frozen_string_literal: true

puts "Creating post statuses for Initech tenant..."

ApplicationRecord.with_tenant("initech") do
  PostStatus.find_or_create_by!(name: "New") do |status|
    status.color = "#3B82F6"
    status.position = 1
  end
  PostStatus.find_or_create_by!(name: "Assigned") do |status|
    status.color = "#F59E0B"
    status.position = 2
  end
  PostStatus.find_or_create_by!(name: "In Progress") do |status|
    status.color = "#8B5CF6"
    status.position = 3
  end
  PostStatus.find_or_create_by!(name: "Blocked") do |status|
    status.color = "#EF4444"
    status.position = 4
  end
  PostStatus.find_or_create_by!(name: "Resolved") do |status|
    status.color = "#10B981"
    status.position = 5
  end
  PostStatus.find_or_create_by!(name: "Won't Fix") do |status|
    status.color = "#6B7280"
    status.position = 6
  end
end

puts "✅ Seeded post statuses for Initech tenant"