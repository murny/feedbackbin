# frozen_string_literal: true

# Inject account associations into Rails framework models for multi-tenancy.
#
# This ensures all ActionText and ActiveStorage records are scoped to an account,
# enabling proper data isolation and account-level queries/cleanup.
#
# The account_id is automatically set via defaults:
# - RichText/Attachment: derived from the parent record's account
# - Blob: uses Current.account (set by controllers)
# - VariantRecord: derived from the parent blob's account
Rails.application.config.to_prepare do
  ActionText::RichText.belongs_to :account, default: -> { record.account }

  ActiveStorage::Attachment.belongs_to :account, default: -> { record.account }

  ActiveStorage::Blob.belongs_to :account, default: -> { Current.account }

  ActiveStorage::VariantRecord.belongs_to :account, default: -> { blob.account }
end
