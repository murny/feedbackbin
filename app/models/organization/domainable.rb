# frozen_string_literal: true

module Organization::Domainable
  extend ActiveSupport::Concern

  included do
    self::SUBDOMAIN_REGEXP = /\A[a-zA-Z0-9]+[a-zA-Z0-9\-_]*[a-zA-Z0-9]+\Z/
    self::RESERVED_DOMAINS = [ "feedbackbin.com" ]
    self::RESERVED_SUBDOMAINS = %w[app help support docs blog status www]

    # To require a domain or subdomain, add the presence validation
    validates :domain, exclusion: { in: self::RESERVED_DOMAINS, message: :reserved },
      uniqueness: { allow_blank: true }

    validates :subdomain, exclusion: { in: self::RESERVED_SUBDOMAINS, message: :reserved },
      format: { with: self::SUBDOMAIN_REGEXP, message: :format, allow_blank: true },
      uniqueness: { allow_blank: true }
  end
end
