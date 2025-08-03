# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if Rails.env.development?
  admin = User.find_or_create_by!(email_address: "shane.murnaghan@feedbackbin.com") do |admin|
    admin.name = "Shane Murnaghan"
    admin.username = "Murny"
    admin.password = "password123"
    admin.site_admin = true
    admin.email_verified = true
  end

  user = User.find_or_create_by!(email_address: "fake_user@example.com") do |user|
    user.name = "Fake User"
    user.username = "FakeUser"
    user.password = "password123"
    user.email_verified = true
  end

  user_two = User.find_or_create_by!(email_address: "jane_doe@example.com") do |user|
    user.name = "Jane Doe"
    user.username = "JaneDoe"
    user.password = "password123"
    user.email_verified = true
  end

  organization = Organization.find_or_create_by!(name: "FeedbackBin", owner: admin)

  PostStatus.find_or_create_by!(name: "In Progress", color: "#FFA500", position: 1, organization: organization)
  PostStatus.find_or_create_by!(name: "Planned", color: "#FF0000", position: 2, organization: organization)
  PostStatus.find_or_create_by!(name: "Archived", color: "#000000", position: 3, organization: organization)
  PostStatus.find_or_create_by!(name: "Complete", color: "#008000", position: 4, organization: organization)

  Membership.find_or_create_by!(organization: organization, user: admin, role: :administrator)
  Membership.find_or_create_by!(organization: organization, user: user, role: :member)
  Membership.find_or_create_by!(organization: organization, user: user_two, role: :member)

  category = Category.find_or_create_by!(name: "Customer Feedback", description: "Share your ideas and help us improve our product", organization: organization)

  post = Post.find_or_create_by!(organization: organization, category: category, author: admin, title: "Could you please add dark mode") do |post|
    post.body = "I would love to see dark mode on this site, please give support for it"
  end

  Comment.find_or_create_by!(organization: organization, post: post, creator: user) do |comment|
    comment.body = "I would also like to see this feature"
  end

  comment = Comment.find_or_create_by!(organization: organization, post: post, creator: user_two) do |comment|
    comment.body = "I agree, dark mode would be great"
  end

  # Replies to the comment
  Comment.find_or_create_by!(organization: organization, parent: comment, post: comment.post, creator: user) do |comment|
    comment.body = "I'm glad you agree, I hope the developers see this"
  end

  Comment.find_or_create_by!(organization: organization, parent: comment, post: comment.post, creator: user_two) do |comment|
    comment.body = "I'm not sure if they will, but I hope so too"
  end

  category.posts.find_or_create_by!(organization: organization, title: "Multiple categories") do |post|
    post.body = "I would like to be able to create multiple categories, is this possible?"
    post.author = admin
  end

  # Add realistic session data for Shane admin user
  Session.find_or_create_by!(user: admin, ip_address: "192.168.1.105") do |session|
    session.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
    session.last_active_at = 2.hours.ago
    session.created_at = 1.week.ago
  end

  Session.find_or_create_by!(user: admin, ip_address: "10.0.0.24") do |session|
    session.user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Mobile/15E148 Safari/604.1"
    session.last_active_at = 1.day.ago
    session.created_at = 3.days.ago
  end

  Session.find_or_create_by!(user: admin, ip_address: "172.16.42.8") do |session|
    session.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
    session.last_active_at = 30.minutes.ago
    session.created_at = 5.days.ago
  end
end
