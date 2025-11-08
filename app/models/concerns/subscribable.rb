# frozen_string_literal: true

module Subscribable
  extend ActiveSupport::Concern

  included do
    has_many :subscriptions, as: :subscribable, dependent: :destroy
    has_many :subscribers, through: :subscriptions, source: :user
  end

  def subscribed_by?(user)
    return false unless user

    subscriptions.active.exists?(user: user)
  end

  def subscribe(user)
    return unless user

    subscription = subscriptions.find_or_initialize_by(user: user)
    if subscription.persisted?
      subscription.subscribe! if subscription.inactive?
    else
      subscription.save
    end
    subscription
  end

  def unsubscribe(user)
    return unless user

    subscription = subscriptions.find_by(user: user)
    subscription&.unsubscribe!
  end

  def active_subscribers
    subscribers.joins(:subscriptions)
               .where(subscriptions: { subscribable: self, unsubscribed_at: nil })
               .distinct
  end
end
