# frozen_string_literal: true

puts "Creating post statuses for Hooli tenant..."

ApplicationRecord.with_tenant("hooli") do
  PostStatus.find_or_create_by!(name: "Under Review") do |status|
    status.color = "#8B5CF6"
    status.position = 1
  end
  PostStatus.find_or_create_by!(name: "Action Required") do |status|
    status.color = "#F59E0B"
    status.position = 2
  end
  PostStatus.find_or_create_by!(name: "In Development") do |status|
    status.color = "#06B6D4"
    status.position = 3
  end
  PostStatus.find_or_create_by!(name: "Shipped") do |status|
    status.color = "#10B981"
    status.position = 4
  end
  PostStatus.find_or_create_by!(name: "Archived") do |status|
    status.color = "#6B7280"
    status.position = 5
  end
end

puts "✅ Seeded post statuses for Hooli tenant"