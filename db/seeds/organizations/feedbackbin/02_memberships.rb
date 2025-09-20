# frozen_string_literal: true

puts "Creating memberships for FeedbackBin tenant..."

ApplicationRecord.with_tenant("feedbackbin") do
  feedbackbin_org = Organization.find_by!(subdomain: "feedbackbin")

  # Find users
  admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")
  fake_user = User.find_by!(email_address: "fake_user@example.com")
  jane_user = User.find_by!(email_address: "jane_doe@example.com")
  alex_user = User.find_by!(email_address: "alex.chen@feedbackbin.com")
  maya_user = User.find_by!(email_address: "maya.patel@feedbackbin.com")
  carlos_user = User.find_by!(email_address: "carlos.rodriguez@feedbackbin.com")
  david_user = User.find_by!(email_address: "david.thompson@feedbackbin.com")

  # Create memberships
  Membership.find_or_create_by!(organization: feedbackbin_org, user: admin_user) do |membership|
    membership.role = :administrator
  end
  Membership.find_or_create_by!(organization: feedbackbin_org, user: fake_user) do |membership|
    membership.role = :member
  end
  Membership.find_or_create_by!(organization: feedbackbin_org, user: jane_user) do |membership|
    membership.role = :member
  end
  Membership.find_or_create_by!(organization: feedbackbin_org, user: alex_user) do |membership|
    membership.role = :member
  end
  Membership.find_or_create_by!(organization: feedbackbin_org, user: maya_user) do |membership|
    membership.role = :administrator
  end
  Membership.find_or_create_by!(organization: feedbackbin_org, user: carlos_user) do |membership|
    membership.role = :member
  end
  Membership.find_or_create_by!(organization: feedbackbin_org, user: david_user) do |membership|
    membership.role = :member
  end
end

puts "✅ Seeded memberships for FeedbackBin tenant"