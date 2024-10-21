# frozen_string_literal: true

module Account::Transferable
  extend ActiveSupport::Concern

  # An account can be transferred by the owner if it:
  # * Has more than one user in it
  def can_transfer?(user)
    owner?(user) && users.size >= 2
  end

  # Transfers ownership of the account to a user
  # The new owner is automatically granted admin access to allow editing of the account
  # Previous owner roles are unchanged
  def transfer_ownership(user_id)
    # previous_owner = owner
    account_user = account_users.find_by!(user_id: user_id)
    user = account_user.user

    ApplicationRecord.transaction do
      account_user.update!(role: :administrator)
      update!(owner: user)

      # Add any additional logic for updating records here
    end

    # Notify the new owner of the change
    # Account::OwnershipNotifier.with(account: self, record: previous_owner).deliver(user)
  rescue
    false
  end
end

# frozen_string_literal: true

# module User::Transferable
#   extend ActiveSupport::Concern

#   TRANSFER_LINK_EXPIRY_DURATION = 4.hours

#   class_methods do
#     def find_by_transfer_id(id)
#       find_signed(id, purpose: :transfer)
#     end
#   end

#   def transfer_id
#     signed_id(purpose: :transfer, expires_in: TRANSFER_LINK_EXPIRY_DURATION)
#   end
# end
