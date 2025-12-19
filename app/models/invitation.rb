# frozen_string_literal: true

class Invitation < ApplicationRecord
  belongs_to :account, default: -> { Current.account }
  belongs_to :invited_by, class_name: "User"

  has_secure_token

  validates :email, presence: true
  validates :name, presence: true
  validates :invited_by, presence: true

  validates :email, uniqueness: { scope: :account_id, message: :invited },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  def save_and_send_invite
    save && send_invite
  end

  def send_invite
    InvitationsMailer.with(invitation: self).invite.deliver_later
  end

  def accept!(user)
    transaction do
      user.identity&.update!(email_verified: true)
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
end
