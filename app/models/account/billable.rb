# module Account::Billable
#   extend ActiveSupport::Concern

#   included do
#     has_one :billing_address, -> { where(address_type: :billing) }, class_name: "Address", as: :addressable
#     has_one :shipping_address, -> { where(address_type: :shipping) }, class_name: "Address", as: :addressable

#     pay_customer stripe_attributes: :stripe_attributes

#     define_method :pay_should_sync_customer? do
#       saved_change_to_owner_id? || saved_change_to_billing_email?
#     end
#   end

#   def find_or_build_billing_address
#     billing_address || build_billing_address
#   end

#   # Email address used for Pay customers and receipts
#   # Defaults to billing_email if defined, otherwise uses the account owner's email
#   def email
#     billing_email? ? billing_email : owner.email
#   end

#   # Used for per-unit subscriptions on create and update
#   # Returns the quantity that should be on the subscription
#   def per_unit_quantity
#     account_users_count
#   end

#   # Attributes to sync to the Stripe Customer
#   def stripe_attributes(*args)
#     {address: billing_address&.to_stripe}.compact
#   end
# end
