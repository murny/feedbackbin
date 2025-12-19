# frozen_string_literal: true

# Need to refactor this as we have identities now. Users are now associated with identities and accounts

puts "Creating users..."

Identity.find_by!(email_address: "shane.murnaghan@feedbackbin.com").join(Account.find_by!(name: "FeedbackBin")) do |user|
  user.name = "Shane Murnaghan"
  user.role = :owner
end

Identity.find_by!(email_address: "jane_doe@example.com").join(Account.find_by!(name: "FeedbackBin")) do |user|
  user.name = "Jane Doe"
  user.role = :admin
end

Identity.find_by!(email_address: "fake_user@example.com").join(Account.find_by!(name: "FeedbackBin")) do |user|
  user.name = "Fake User"
  user.role = :member
end

Identity.find_by!(email_address: "sarah.kim@startup.io").join(Account.find_by!(name: "FeedbackBin")) do |user|
  user.name = "Sarah Kim"
  user.role = :member
end

Identity.find_by!(email_address: "david.thompson@agency.com").join(Account.find_by!(name: "FeedbackBin")) do |user|
  user.name = "David Thompson"
  user.role = :member
end

Identity.find_by!(email_address: "alex.chen@techcorp.com").join(Account.find_by!(name: "FeedbackBin")) do |user|
  user.name = "Alex Chen"
  user.role = :member
end

Identity.find_by!(email_address: "maya.patel@designstudio.co").join(Account.find_by!(name: "FeedbackBin")) do |user|
  user.name = "Maya Patel"
  user.role = :member
end

Identity.find_by!(email_address: "carlos.rodriguez@freelance.dev").join(Account.find_by!(name: "FeedbackBin")) do |user|
  user.name = "Carlos Rodriguez"
  user.role = :member
end


puts "✅ Seeded users"
