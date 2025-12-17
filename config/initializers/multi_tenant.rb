# frozen_string_literal: true

# Multi-tenant configuration
# Set MULTI_TENANT=true in your environment to enable multi-tenant mode
Rails.application.config.multi_tenant = ENV.fetch("MULTI_TENANT", "false") == "true"
