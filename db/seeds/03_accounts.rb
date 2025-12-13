# frozen_string_literal: true

puts "Creating accounts..."

account_attrs = { name: "FeedbackBin" }
account_attrs[:subdomain] = "feedbackbin" if Rails.application.config.multi_tenant

account = Account.find_or_create_by!(account_attrs)
Current.account = account

if account.default_status.nil?
  default = Status.where(account: account).ordered.first
  account.update!(default_status: default) if default
end

puts "✅ Seeded accounts"
