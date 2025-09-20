# frozen_string_literal: true

puts "Creating users for Initech tenant..."

# Set tenant context
ApplicationRecord.with_tenant("initech") do
  initech_org = Organization.find_by!(subdomain: "initech")

  # Bill Lumbergh - VP
  User.find_or_create_by!(email_address: "bill.lumbergh@initech.com") do |user|
    user.name = "Bill Lumbergh"
    user.username = "blumbergh"
    user.password = "password123"
    user.bio = "VP at Initech. Yeah, if you could just go ahead and use this feedback system, that'd be great."
    user.preferred_language = "en"
    user.time_zone = "America/Chicago"
    user.email_verified = true
  end

  # Peter Gibbons - Software Engineer
  User.find_or_create_by!(email_address: "peter.gibbons@initech.com") do |user|
    user.name = "Peter Gibbons"
    user.username = "pgibbons"
    user.password = "password123"
    user.bio = "Software Engineer. I'd say in a given week I probably only do about fifteen minutes of real, actual work."
    user.preferred_language = "en"
    user.time_zone = "America/Chicago"
    user.email_verified = true
  end

  # Michael Bolton - Software Engineer
  User.find_or_create_by!(email_address: "michael.bolton@initech.com") do |user|
    user.name = "Michael Bolton"
    user.username = "mbolton"
    user.password = "password123"
    user.bio = "Software Engineer. No talent ass-clown. Wait, that's the singer. I'm the programmer."
    user.preferred_language = "en"
    user.time_zone = "America/Chicago"
    user.email_verified = true
  end

  # Samir Nagheenanajar - Software Engineer
  User.find_or_create_by!(email_address: "samir.nagheenanajar@initech.com") do |user|
    user.name = "Samir Nagheenanajar"
    user.username = "snagheenanajar"
    user.password = "password123"
    user.bio = "Software Engineer. Back up in your ass with the resurrection. Also, my name is not that hard to pronounce."
    user.preferred_language = "en"
    user.time_zone = "America/Chicago"
    user.email_verified = true
  end

  # Tom Smykowski - Quality Assurance
  User.find_or_create_by!(email_address: "tom.smykowski@initech.com") do |user|
    user.name = "Tom Smykowski"
    user.username = "tsmykowski"
    user.password = "password123"
    user.bio = "Quality Assurance. I deal with the goddamn customers so the engineers don't have to!"
    user.preferred_language = "en"
    user.time_zone = "America/Chicago"
    user.email_verified = true
  end

  # Milton Waddams - Storage Specialist
  User.find_or_create_by!(email_address: "milton.waddams@initech.com") do |user|
    user.name = "Milton Waddams"
    user.username = "mwaddams"
    user.password = "password123"
    user.bio = "Storage Specialist in B-4. I could set the building on fire. Also, please don't take my stapler."
    user.preferred_language = "en"
    user.time_zone = "America/Chicago"
    user.email_verified = true
  end

  # Jennifer Aniston - Waitress (works part time at Initech)
  User.find_or_create_by!(email_address: "joanna@initech.com") do |user|
    user.name = "Joanna"
    user.username = "joanna"
    user.password = "password123"
    user.bio = "Administrative Assistant. Just looking for someone who wants to do nothing and hang out all day."
    user.preferred_language = "en"
    user.time_zone = "America/Chicago"
    user.email_verified = true
  end

  # Set organization owner
  owner_user = User.find_by!(email_address: "bill.lumbergh@initech.com")
  initech_org.update!(owner: owner_user)
end

puts "✅ Seeded users for Initech tenant"