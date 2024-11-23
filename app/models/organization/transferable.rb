# frozen_string_literal: true

module Organization::Transferable
  extend ActiveSupport::Concern

  # An organization can be transferred by the owner if it:
  # * Has more than one user in it
  def can_transfer?(user)
    owner?(user) && users.size >= 2
  end

  # Transfers ownership of the organization to a user
  # The new owner is automatically granted admin access to allow editing of the organization
  # Previous owner roles are unchanged
  def transfer_ownership(user_id)
    # previous_owner = owner
    membership = memberships.find_by!(user_id: user_id)
    user = membership.user

    ApplicationRecord.transaction do
      membership.update!(role: :administrator)
      update!(owner: user)

      # Add any additional logic for updating records here
    end

    # Notify the new owner of the change
    # Organization::OwnershipNotifier.with(organization: self, record: previous_owner).deliver(user)
  rescue
    false
  end
end

# TODO: Remove when the following code is implemented
#
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
