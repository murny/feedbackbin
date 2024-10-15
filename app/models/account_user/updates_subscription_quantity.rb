module UpdatesSubscriptionQuantity
  # Per Unit subscriptions (i.e. $10/user/mo) can include this module to add callbacks
  # to automatically update the subscription quantity when records are created or destroyed.
  #
  # This module should be included on the resource that is being measured. For example, with
  # $10/user/month pricing, it would go on the AccountUser model to count the users per account.
  #
  # Another example if an Account has_many :sites, you would include this module on the Site model.
  # When a site is created or destroyed, the account's subscription quantity would be updated to match.
  #
  # You'll also need to implement the `per_unit_quantity` on Account to return the quantity to be set on new subscriptions.
  #
  # Usage:
  #
  #    class Site
  #      include UpdatesSubscriptionQuantity
  #
  #      belongs_to :account, counter_cache: true
  #
  #      updates_subscription_quantity :per_unit_quantity
  #      # or with a block/callable object
  #      # updates_subscription_quantity ->{ account.per_unit_quantity }
  #    end
  #
  #    class Account
  #      def per_unit_quantity
  #        account.sites_count # Use counter cache for performance
  #      end
  #    end

  extend ActiveSupport::Concern

  included do
    cattr_accessor :_quantity_callback
  end

  class_methods do
    def updates_subscription_quantity(method_or_callable = nil, &block)
      self._quantity_callback = method_or_callable || block

      # Trigger after commit so changes have been committed to the db successfully
      after_commit :update_subscription_quantity, on: [:create, :destroy]
    end
  end

  def update_subscription_quantity
    subscription = account&.payment_processor&.subscription
    return unless subscription&.active? && subscription.plan&.charge_per_unit?

    new_quantity = case _quantity_callback
    when Symbol
      send(_quantity_callback)
    else
      instance_exec(&_quantity_callback)
    end

    subscription.change_quantity(new_quantity)
  end
end
