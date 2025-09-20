# frozen_string_literal: true

puts "Creating users for Hooli tenant..."

# Set tenant context
ApplicationRecord.with_tenant("hooli") do
  hooli_org = Organization.find_by!(subdomain: "hooli")

  # Gavin Belson - CEO
  User.find_or_create_by!(email_address: "gavin.belson@hooli.com") do |user|
    user.name = "Gavin Belson"
    user.username = "gbelson"
    user.password = "password123"
    user.bio = "CEO of Hooli. Making the world a better place through minimal message-oriented transport layers."
    user.preferred_language = "en"
    user.time_zone = "America/Los_Angeles"
    user.email_verified = true
  end

  # Jack Barker - Action Jack
  User.find_or_create_by!(email_address: "jack.barker@hooli.com") do |user|
    user.name = "Jack Barker"
    user.username = "actionjack"
    user.password = "password123"
    user.bio = "Head of Business Development. Let's action this and circle back offline to ideate some solutions."
    user.preferred_language = "en"
    user.time_zone = "America/Los_Angeles"
    user.email_verified = true
  end

  # Denpok (Head of Spiritual Development)
  User.find_or_create_by!(email_address: "denpok@hooli.com") do |user|
    user.name = "Denpok"
    user.username = "denpok"
    user.password = "password123"
    user.bio = "Head of Spiritual Development. Bringing mindfulness and inner peace to the Hooli workplace."
    user.preferred_language = "en"
    user.time_zone = "America/Los_Angeles"
    user.email_verified = true
  end

  # Jeff Hartman - Hooli Employee
  User.find_or_create_by!(email_address: "jeff.hartman@hooli.com") do |user|
    user.name = "Jeff Hartman"
    user.username = "jhartman"
    user.password = "password123"
    user.bio = "Senior Software Engineer. Building the platform to make the world a better place."
    user.preferred_language = "en"
    user.time_zone = "America/Los_Angeles"
    user.email_verified = true
  end

  # Hooli XYZ Team Member
  User.find_or_create_by!(email_address: "patrice.henderson@hooli.com") do |user|
    user.name = "Patrice Henderson"
    user.username = "phenderson"
    user.password = "password123"
    user.bio = "Product Manager on Hooli XYZ. Focused on disrupting the disruption."
    user.preferred_language = "en"
    user.time_zone = "America/Los_Angeles"
    user.email_verified = true
  end

  # Network Security Engineer
  User.find_or_create_by!(email_address: "ben.rogers@hooli.com") do |user|
    user.name = "Ben Rogers"
    user.username = "brogers"
    user.password = "password123"
    user.bio = "Senior Network Security Engineer. Keeping Hooli's data safe from industrial espionage."
    user.preferred_language = "en"
    user.time_zone = "America/Los_Angeles"
    user.email_verified = true
  end

  # UI/UX Designer
  User.find_or_create_by!(email_address: "tracy.williams@hooli.com") do |user|
    user.name = "Tracy Williams"
    user.username = "twilliams"
    user.password = "password123"
    user.bio = "Principal UX Designer. Creating beautiful, intuitive interfaces for Hooli's ecosystem."
    user.preferred_language = "en"
    user.time_zone = "America/Los_Angeles"
    user.email_verified = true
  end

  # Set organization owner
  owner_user = User.find_by!(email_address: "gavin.belson@hooli.com")
  hooli_org.update!(owner: owner_user)
end

puts "✅ Seeded users for Hooli tenant"