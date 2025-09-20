# frozen_string_literal: true

puts "Creating memberships for Initech tenant..."

ApplicationRecord.with_tenant("initech") do
  initech_org = Organization.find_by!(subdomain: "initech")

  # Find users
  bill_user = User.find_by!(email_address: "bill.lumbergh@initech.com")
  peter_user = User.find_by!(email_address: "peter.gibbons@initech.com")
  michael_user = User.find_by!(email_address: "michael.bolton@initech.com")
  samir_user = User.find_by!(email_address: "samir.nagheenanajar@initech.com")
  tom_user = User.find_by!(email_address: "tom.smykowski@initech.com")
  milton_user = User.find_by!(email_address: "milton.waddams@initech.com")
  joanna_user = User.find_by!(email_address: "joanna@initech.com")

  # Create memberships - Bill as admin, Tom as admin (QA lead), others as members
  Membership.find_or_create_by!(organization: initech_org, user: bill_user) do |membership|
    membership.role = :administrator
  end
  Membership.find_or_create_by!(organization: initech_org, user: tom_user) do |membership|
    membership.role = :administrator
  end
  Membership.find_or_create_by!(organization: initech_org, user: peter_user) do |membership|
    membership.role = :member
  end
  Membership.find_or_create_by!(organization: initech_org, user: michael_user) do |membership|
    membership.role = :member
  end
  Membership.find_or_create_by!(organization: initech_org, user: samir_user) do |membership|
    membership.role = :member
  end
  Membership.find_or_create_by!(organization: initech_org, user: milton_user) do |membership|
    membership.role = :member
  end
  Membership.find_or_create_by!(organization: initech_org, user: joanna_user) do |membership|
    membership.role = :member
  end
end

puts "✅ Seeded memberships for Initech tenant"