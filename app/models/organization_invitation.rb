# frozen_string_literal: true

class OrganizationInvitation < ApplicationRecord
  belongs_to :organization
  belongs_to :invited_by, class_name: "User", optional: true

  has_secure_token

  validates :name, :email, presence: true

  # TODO: Add email format validation and should this be scoped to organization_id?
  validates :email, uniqueness: {scope: :organization_id, message: :invited}

  def save_and_send_invite
    save && send_invite
  end

  def send_invite
    OrganizationInvitationsMailer.with(organization_invitation: self).invite.deliver_later
  end

  def accept!(user)
    membership = organization.memberships.new(user: user, role: :member)
    if membership.valid?
      ApplicationRecord.transaction do
        membership.save!
        destroy!
      end

      # [organization.owner, invited_by].uniq.each do |recipient|
      #   Organization::AcceptedInviteNotifier.with(organization: organization, record: user).deliver(recipient)
      # end

      membership
    else
      errors.add(:base, membership.errors.full_messages.first)
      nil
    end
  end

  def reject!
    destroy
  end

  def to_param
    token
  end
end
