# frozen_string_literal: true

module AccountSlug
  MINIMUM_DIGITS = 7
  SLUG_PATTERN = /\A\/(\d{#{MINIMUM_DIGITS},})(\/.*|)\z/

  class << self
    # Encode account ID to slug format (7+ digit zero-padded)
    # Returns format like "/1234567"
    def encode(external_account_id)
      format("/%0#{MINIMUM_DIGITS}d", external_account_id)
    end

    # Decode slug to external_account_id
    def decode(slug)
      slug.to_s.delete_prefix("/").to_i
    end

    # Extract external_account_id and remaining path from a full path
    # Returns [external_account_id, remaining_path] or [nil, original_path]
    def extract(path)
      if (match = SLUG_PATTERN.match(path))
        [ match[1].to_i, match[2].presence || "/" ]
      else
        [ nil, path ]
      end
    end
  end

  # Rack middleware that extracts account from URL path
  class Extractor
    def initialize(app)
      @app = app
    end

    def call(env)
      path_info = env["PATH_INFO"]
      external_account_id, remaining_path = AccountSlug.extract(path_info)

      if external_account_id
        account = Account.find_by(external_account_id: external_account_id)

        if account
          # Rewrite SCRIPT_NAME and PATH_INFO for Rails routing
          env["SCRIPT_NAME"] = AccountSlug.encode(external_account_id)
          env["PATH_INFO"] = remaining_path
          env["feedbackbin.external_account_id"] = external_account_id

          Current.with_account(account) { @app.call(env) }
        else
          # Unknown account - let controller handle redirect to account selection
          # This provides better UX than a 404
          Current.without_account { @app.call(env) }
        end
      else
        Current.without_account { @app.call(env) }
      end
    end
  end
end

# Insert middleware early in stack, after TempfileReaper
# Current.with_account blocks wrap the entire request lifecycle
Rails.application.config.middleware.insert_after Rack::TempfileReaper, AccountSlug::Extractor
