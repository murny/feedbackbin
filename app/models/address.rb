# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  enum :address_type, {billing: 0, shipping: 1}

  validates :address_type, presence: true
  validates :line1, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true
  validates :country, presence: true

  after_commit :update_pay_customer_addresses, if: -> { billing? && addressable.respond_to?(:pay_customers) }

  def to_stripe
    {
      city: city,
      country: country,
      line1: line1,
      line2: line2,
      postal_code: postal_code,
      state: state
    }
  end

  private

  def update_pay_customer_addresses
    addressable.pay_customers.each(&:update_customer!)
  end
end
