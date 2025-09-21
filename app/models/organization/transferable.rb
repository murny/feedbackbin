# frozen_string_literal: true

class Organization
  module Transferable
    extend ActiveSupport::Concern

    # NOTE: In single tenancy mode, organization transfer functionality is deprecated
    # This module is kept for compatibility but functionality is disabled

    def can_transfer?(user)
      false # Transfers are not supported in single tenancy mode
    end

    def transfer_ownership(user_id)
      false # Transfers are not supported in single tenancy mode
    end
  end
end
