# frozen_string_literal: true

puts "Creating categories for Hooli tenant..."

ApplicationRecord.with_tenant("hooli") do
  Category.find_or_create_by!(name: "Hooli XYZ") do |category|
    category.description = "Feedback and suggestions for our groundbreaking Hooli XYZ platform"
  end
  Category.find_or_create_by!(name: "HooliPhone") do |category|
    category.description = "Issues and improvements for the revolutionary HooliPhone ecosystem"
  end
  Category.find_or_create_by!(name: "Box Initiative") do |category|
    category.description = "The future of connectivity - feedback on our Box products"
  end
  Category.find_or_create_by!(name: "Platform & Infrastructure") do |category|
    category.description = "Core platform improvements to make the world a better place"
  end
  Category.find_or_create_by!(name: "Workplace Culture") do |category|
    category.description = "Spiritual development and workplace wellness initiatives"
  end
end

puts "✅ Seeded categories for Hooli tenant"