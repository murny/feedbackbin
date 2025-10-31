# frozen_string_literal: true

class Invitation < ApplicationRecord
  belongs_to :invited_by, class_name: "User"
  belongs_to :accepted_by, class_name: "User", optional: true

  has_secure_token

  validates :email, presence: true
  validates :name, presence: true
  validates :invited_by, presence: true

  validates :email, uniqueness: { message: :invited },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  # Scopes
  scope :pending, -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }
  scope :expired, -> { where(accepted_at: nil).where("expires_at <= ?", Time.current) }
  scope :accepted, -> { where.not(accepted_at: nil) }

  # Set default expiration on create
  before_create :set_expiration

  def save_and_send_invite
    save && send_invite
  end

  def send_invite
    InvitationMailer.with(invitation: self).invite.deliver_later
  end

  def accept!(user)
    transaction do
      update!(
        accepted_at: Time.current,
        accepted_by: user
      )
    end
  end

  def reject!
    destroy!
  end

  def expired?
    expires_at && expires_at < Time.current && accepted_at.nil?
  end

  def pending?
    accepted_at.nil? && !expired?
  end

  def accepted?
    accepted_at.present?
  end

  def to_param
    token
  end

  private

    def set_expiration
      self.expires_at ||= 7.days.from_now
    end
end
