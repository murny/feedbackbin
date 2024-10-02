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
  User.find_or_create_by!(email_address: "shane.murnaghan@feedbackbin.com") do |admin|
    admin.name = "Shane Murnaghan"
    admin.username = "Murny"
    admin.password = "password123"
    admin.password_confirmation = "password123"
    admin.email_verified = true
    admin.role = User.roles[:administrator]
  end

  Post.find_or_create_by!(title: "Could you please add dark mode") do |post|
    post.description = "I would love to see dark mode on this site, please give support for it"
  end

  Post.find_or_create_by!(title: "Multiple boards?") do |post|
    post.description = "I would like to be able to create multiple boards, is this possible?"
  end
end
