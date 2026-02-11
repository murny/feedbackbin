# frozen_string_literal: true

# Enforce tenant safety for ActiveStorage attachments and tighten blob reuse.
#
# Invariants:
# 1) blob.account_id must match record.account_id
# 2) blobs cannot be reused in tracked contexts
#    (except ActionText embeds to support copy/paste flows)
module ActiveStorageTenantSafety
  TRACKED_RECORD_TYPES = %w[Account User ActionText::RichText].freeze
end

ActiveSupport.on_load(:active_storage_attachment) do
  validate :blob_account_matches_record, on: :create
  validate :no_tracked_blob_reuse, on: :create

  private
    def blob_account_matches_record
      return if blob.blank?
      return if record&.try(:account).blank?

      if blob.account_id != record.account.id
        errors.add(:blob_id, "blob account must match record account")
      end
    end

    def no_tracked_blob_reuse
      return if blob_id.blank?
      return if action_text_embed_attachment?
      return unless ActiveStorageTenantSafety::TRACKED_RECORD_TYPES.include?(record_type)

      existing_tracked_attachment = ActiveStorage::Attachment
        .where(blob_id: blob_id, record_type: ActiveStorageTenantSafety::TRACKED_RECORD_TYPES)
        .where.not(id: id)
        .exists?

      if existing_tracked_attachment
        errors.add(:blob_id, "cannot reuse blob in tracked storage context")
      end
    end

    def action_text_embed_attachment?
      record_type == "ActionText::RichText" && name == "embeds"
    end
end
