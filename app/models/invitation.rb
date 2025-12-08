# frozen_string_literal: true

class Invitation < ApplicationRecord
  EXPIRATION_TIME = 30.days

  belongs_to :invited_by, class_name: "User"

  has_secure_token

  validates :email, presence: true
  validates :name, presence: true
  validates :invited_by, presence: true

  validates :email, uniqueness: { message: :invited },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :expired, -> { where("created_at < ?", EXPIRATION_TIME.ago) }

  def save_and_send_invite
    save && send_invite
  end

  def send_invite
    InvitationsMailer.with(invitation: self).invite.deliver_later
  end

  def accept!(user)
    transaction do
      user.update!(email_verified: true)
      destroy!
    end

    # TODO: Send notification to inviter when invitation is accepted
    # AcceptedInviteNotifier.with(record: user).deliver(invited_by)
  end

  def reject!
    destroy!
  end

  def to_param
    token
  end

  # Cleanup expired invitations
  def self.cleanup_expired(older_than: EXPIRATION_TIME.ago)
    where("created_at < ?", older_than).delete_all
  end
end
