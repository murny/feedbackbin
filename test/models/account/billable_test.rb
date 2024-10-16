# frozen_string_literal: true

require "test_helper"

class Account::BillableTest < ActiveSupport::TestCase
  test "billing_email shouldn't be included in receipts if empty" do
    account = accounts(:company)
    account.update!(billing_email: nil)
    pay_customer = account.set_payment_processor :fake_processor, allow_fake: true
    pay_charge = pay_customer.charge(10_00)

    mail = Pay::UserMailer.with(pay_customer: pay_customer, pay_charge: pay_charge).receipt

    assert_equal [account.email], mail.to
  end

  test "billing_email should be included in receipts if present" do
    account = accounts(:company)
    account.update!(billing_email: "accounting@example.com")
    pay_customer = account.set_payment_processor :fake_processor, allow_fake: true
    pay_charge = pay_customer.charge(10_00)

    mail = Pay::UserMailer.with(pay_customer: pay_customer, pay_charge: pay_charge).receipt

    assert_equal ["accounting@example.com"], mail.to
  end

  # test "account can be subscribed" do
  #   assert_predicate accounts(:subscribed).payment_processor, :subscribed?
  # end
end
