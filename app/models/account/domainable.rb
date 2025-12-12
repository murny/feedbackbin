# frozen_string_literal: true

class Account
  module Domainable
    extend ActiveSupport::Concern

    included do
      self::SUBDOMAIN_REGEXP = /\A[a-zA-Z0-9]+[a-zA-Z0-9\-_]*[a-zA-Z0-9]+\Z/
      self::RESERVED_SUBDOMAINS = %w[app help support docs blog status www]

      validates :subdomain, presence: true, if: -> { Rails.application.config.multi_tenant }
      validates :subdomain,
        exclusion: { in: self::RESERVED_SUBDOMAINS, message: :reserved },
        format: { with: self::SUBDOMAIN_REGEXP, message: :format },
        length: { minimum: 3, maximum: 50 },
        uniqueness: true,
        allow_blank: true

      normalizes :subdomain, with: ->(subdomain) { subdomain&.downcase&.squish }
    end
  end
end
