class AccountInvitation < ApplicationRecord
  ROLES = AccountUser::ROLES

  include AccountUser::Roles

  belongs_to :account
  belongs_to :invited_by, class_name: "User", optional: true
  has_secure_token

  validates :name, :email, presence: true
  validates :email, uniqueness: {scope: :account_id, message: :invited}

  def save_and_send_invite
    save && send_invite
  end

  def send_invite
    AccountInvitationsMailer.with(account_invitation: self).invite.deliver_later
  end

  def accept!(user)
    account_user = account.account_users.new(user: user, roles: roles)
    if account_user.valid?
      ApplicationRecord.transaction do
        account_user.save!
        destroy!
      end

      [account.owner, invited_by].uniq.each do |recipient|
        Account::AcceptedInviteNotifier.with(account: account, record: user).deliver(recipient)
      end

      account_user
    else
      errors.add(:base, account_user.errors.full_messages.first)
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
