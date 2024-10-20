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

Status.find_or_create_by!(name: "In Progress", color: "#FFA500", position: 1)
Status.find_or_create_by!(name: "Planned", color: "#FF0000", position: 2)
Status.find_or_create_by!(name: "Archived", color: "#000000", position: 3)
Status.find_or_create_by!(name: "Complete", color: "#008000", position: 4)

if Rails.env.development?
  admin = User.find_or_create_by!(email_address: "shane.murnaghan@feedbackbin.com") do |admin|
    admin.name = "Shane Murnaghan"
    admin.username = "Murny"
    admin.password = "password123"
    admin.email_verified = true
    admin.role = User.roles[:administrator]
  end

  user = User.find_or_create_by!(email_address: "fake_user@example.com") do |user|
    user.name = "Fake User"
    user.username = "FakeUser"
    user.password = "password123"
    user.email_verified = true
    user.role = User.roles[:member]
  end

  user_two = User.find_or_create_by!(email_address: "jane_doe@example.com") do |user|
    user.name = "Jane Doe"
    user.username = "JaneDoe"
    user.password = "password123"
    user.email_verified = true
    user.role = User.roles[:member]
  end

  Account.find_or_create_by!(name: "FeedbackBin")

  board = Board.find_or_create_by!(name: "Feature Requests")

  post = board.posts.find_or_create_by!(title: "Could you please add dark mode") do |post|
    post.body = "I would love to see dark mode on this site, please give support for it"
    post.author = admin
  end

  # create a few comments and replies for the post using ActionText
  post.comments.create!(body: "I would also like to see this feature", creator: user)
  comment = post.comments.create!(body: "I agree, dark mode would be great", creator: user_two)

  comment.replies.create!(body: "I'm glad you agree, I hope the developers see this", creator: user)
  comment.replies.create!(body: "I'm not sure if they will, but I hope so too", creator: user_two)

  board.posts.find_or_create_by!(title: "Multiple boards?") do |post|
    post.body = "I would like to be able to create multiple boards, is this possible?"
    post.author = admin
  end
end
