# frozen_string_literal: true

require "test_helper"

class ActiveStorage::AttachmentTenantSafetyTest < ActiveSupport::TestCase
  test "rejects cross-tenant blob attachment" do
    feedbackbin_blob = Current.with_account(accounts(:feedbackbin)) do
      create_blob(filename: "feedbackbin-logo.txt")
    end

    attachment = ActiveStorage::Attachment.new(
      name: "logo",
      record: accounts(:acme),
      blob: feedbackbin_blob
    )

    assert_not attachment.valid?
    assert_includes attachment.errors[:blob_id], "blob account must match record account"
  end

  test "rejects blob reuse in tracked contexts" do
    blob = Current.with_account(accounts(:feedbackbin)) do
      create_blob(filename: "tracked-reuse.txt")
    end

    ActiveStorage::Attachment.create!(
      name: "logo",
      record: accounts(:feedbackbin),
      blob: blob
    )

    reused_attachment = ActiveStorage::Attachment.new(
      name: "favicon",
      record: accounts(:feedbackbin),
      blob: blob
    )

    assert_not reused_attachment.valid?
    assert_includes reused_attachment.errors[:blob_id], "cannot reuse blob in tracked storage context"
  end

  test "allows ActionText embed blob reuse" do
    account = accounts(:feedbackbin)

    blob = Current.with_account(account) do
      create_blob(filename: "embedded-image.txt")
    end

    rich_text_one = ActionText::RichText.create!(
      account: account,
      record: ideas(:one),
      name: "tenant_safety_embed_one",
      body: "<div>one</div>"
    )

    rich_text_two = ActionText::RichText.create!(
      account: account,
      record: ideas(:two),
      name: "tenant_safety_embed_two",
      body: "<div>two</div>"
    )

    first_attachment = ActiveStorage::Attachment.new(
      name: "embeds",
      record: rich_text_one,
      blob: blob
    )

    second_attachment = ActiveStorage::Attachment.new(
      name: "embeds",
      record: rich_text_two,
      blob: blob
    )

    assert_predicate first_attachment, :valid?
    assert_predicate second_attachment, :valid?
  end

  private
    def create_blob(filename:)
      ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new("tenant safety blob"),
        filename: filename,
        content_type: "text/plain"
      )
    end
end
