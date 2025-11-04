# frozen_string_literal: true

class Invitation < ApplicationRecord
  belongs_to :invited_by, class_name: "User"

  has_secure_token

  validates :email, presence: true
  validates :name, presence: true
  validates :invited_by, presence: true

  validates :email, uniqueness: { message: :invited },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  def save_and_send_invite
    save && send_invite
  end

  def send_invite
    InvitationsMailer.with(invitation: self).invite.deliver_later
  end

  def accept!
    # TODO:
    # we can pass in the user to be created here and this can be in a transaction

    destroy!

    # TODO: Send notification to owner and invited by?
  end

  def reject!
    destroy!
  end

  def to_param
    token
  end
end
