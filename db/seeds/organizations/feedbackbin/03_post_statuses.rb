# frozen_string_literal: true

puts "Creating post statuses for FeedbackBin tenant..."

ApplicationRecord.with_tenant("feedbackbin") do
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

puts "✅ Seeded post statuses for FeedbackBin tenant"