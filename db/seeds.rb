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
