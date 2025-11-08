# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :subscribable, polymorphic: true

  validates :user_id, uniqueness: { scope: [ :subscribable_type, :subscribable_id ] }

  scope :active, -> { where(unsubscribed_at: nil) }
  scope :inactive, -> { where.not(unsubscribed_at: nil) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_subscribable, ->(subscribable) { where(subscribable: subscribable) }

  before_create :set_subscribed_at

  def active?
    unsubscribed_at.nil?
  end

  def inactive?
    !active?
  end

  def subscribe!
    update!(unsubscribed_at: nil, subscribed_at: Time.current)
  end

  def unsubscribe!
    update!(unsubscribed_at: Time.current)
  end

  private

    def set_subscribed_at
      self.subscribed_at ||= Time.current
    end
end
