# frozen_string_literal: true

puts "Creating categories for Initech tenant..."

ApplicationRecord.with_tenant("initech") do
  Category.find_or_create_by!(name: "Y2K Compliance") do |category|
    category.description = "Year 2000 compliance issues and updates for legacy systems"
  end
  Category.find_or_create_by!(name: "TPS Reports") do |category|
    category.description = "Testing Procedure Specification reports and related processes"
  end
  Category.find_or_create_by!(name: "Office Equipment") do |category|
    category.description = "Printer jams, fax machine issues, and other office equipment problems"
  end
  Category.find_or_create_by!(name: "Software Development") do |category|
    category.description = "Code improvements, bug fixes, and development process feedback"
  end
  Category.find_or_create_by!(name: "Workplace Issues") do |category|
    category.description = "General workplace concerns and administrative matters"
  end
end

puts "✅ Seeded categories for Initech tenant"