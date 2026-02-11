# frozen_string_literal: true

# Preserves Current.account context across background job serialization/deserialization
# This ensures jobs that broadcast Turbo Streams have the correct account context
module TenantedActiveJobExtensions
  extend ActiveSupport::Concern

  prepended do
    attr_reader :account
    self.enqueue_after_transaction_commit = true
  end

  def initialize(...)
    super
    @account = Current.account
  end

  def serialize
    super.merge("account" => @account&.to_gid&.to_s)
  end

  def deserialize(job_data)
    super
    if (account_gid = job_data.fetch("account", nil))
      @account = GlobalID::Locator.locate(account_gid)
    end
  end

  def perform_now
    if account.present?
      Current.with_account(account) { super }
    else
      super
    end
  end
end

ActiveSupport.on_load(:active_job) do
  prepend TenantedActiveJobExtensions
end
