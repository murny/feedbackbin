# frozen_string_literal: true

puts "Creating memberships for Hooli tenant..."

ApplicationRecord.with_tenant("hooli") do
  hooli_org = Organization.find_by!(subdomain: "hooli")

  # Find users
  gavin_user = User.find_by!(email_address: "gavin.belson@hooli.com")
  jack_user = User.find_by!(email_address: "jack.barker@hooli.com")
  denpok_user = User.find_by!(email_address: "denpok@hooli.com")
  jeff_user = User.find_by!(email_address: "jeff.hartman@hooli.com")
  patrice_user = User.find_by!(email_address: "patrice.henderson@hooli.com")
  ben_user = User.find_by!(email_address: "ben.rogers@hooli.com")
  tracy_user = User.find_by!(email_address: "tracy.williams@hooli.com")

  # Create memberships - Gavin as admin, Jack as admin, others as members
  Membership.find_or_create_by!(organization: hooli_org, user: gavin_user) do |membership|
    membership.role = :administrator
  end
  Membership.find_or_create_by!(organization: hooli_org, user: jack_user) do |membership|
    membership.role = :administrator
  end
  Membership.find_or_create_by!(organization: hooli_org, user: denpok_user) do |membership|
    membership.role = :member
  end
  Membership.find_or_create_by!(organization: hooli_org, user: jeff_user) do |membership|
    membership.role = :member
  end
  Membership.find_or_create_by!(organization: hooli_org, user: patrice_user) do |membership|
    membership.role = :administrator
  end
  Membership.find_or_create_by!(organization: hooli_org, user: ben_user) do |membership|
    membership.role = :member
  end
  Membership.find_or_create_by!(organization: hooli_org, user: tracy_user) do |membership|
    membership.role = :member
  end
end

puts "✅ Seeded memberships for Hooli tenant"