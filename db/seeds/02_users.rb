# frozen_string_literal: true

puts "Creating users..."

account = Account.find_by!(name: "FeedbackBin")
Current.account = account

def seed_identity_and_membership!(account:, email:, name:, password: "password123", role: :member, super_admin: false, email_verified: true, **user_attrs)
  identity = Identity.find_or_initialize_by(email_address: email)
  identity.password = password if identity.new_record?
  identity.super_admin = super_admin
  identity.save! if identity.changed? || identity.new_record?

  user = User.find_or_initialize_by(identity: identity, account: account)
  user.name = name
  user.role = role
  user.email_verified = email_verified
  user.assign_attributes(user_attrs)
  user.save!

  user
end

seed_identity_and_membership!(
  account: account,
  email: "shane.murnaghan@feedbackbin.com",
  name: "Shane Murnaghan",
  role: :owner,
  super_admin: true,
  email_verified: true
)

seed_identity_and_membership!(
  account: account,
  email: "fake_user@example.com",
  name: "Fake User",
  role: :member,
  email_verified: true
)

seed_identity_and_membership!(
  account: account,
  email: "jane_doe@example.com",
  name: "Jane Doe",
  role: :admin,
  email_verified: true
)

# Additional creative users with detailed profiles
seed_identity_and_membership!(
  account: account,
  email: "alex.chen@techcorp.com",
  name: "Alex Chen",
  bio: "Product manager passionate about user experience. Coffee enthusiast and weekend rock climber.",
  preferred_language: "en",
  time_zone: "America/Los_Angeles",
  email_verified: true
)

seed_identity_and_membership!(
  account: account,
  email: "maya.patel@designstudio.co",
  name: "Maya Patel",
  bio: "UX Designer with 8 years experience. Love creating intuitive interfaces that users actually enjoy.",
  preferred_language: "en",
  time_zone: "America/New_York",
  email_verified: true
)

seed_identity_and_membership!(
  account: account,
  email: "carlos.rodriguez@freelance.dev",
  name: "Carlos Rodriguez",
  bio: "Full-stack developer and digital nomad. Currently coding from Barcelona 🇪🇸",
  preferred_language: "es",
  time_zone: "Europe/Madrid",
  email_verified: true
)

seed_identity_and_membership!(
  account: account,
  email: "sarah.kim@startup.io",
  name: "Sarah Kim",
  bio: "Marketing director turned product owner. Obsessed with data-driven decisions and user feedback loops.",
  preferred_language: "en",
  time_zone: "America/Chicago",
  email_verified: true
)

seed_identity_and_membership!(
  account: account,
  email: "david.thompson@agency.com",
  name: "David Thompson",
  bio: "Creative director with a knack for spotting design inconsistencies. Advocate for accessibility in digital products.",
  preferred_language: "en",
  time_zone: "America/New_York",
  email_verified: true
)

puts "✅ Seeded users"
