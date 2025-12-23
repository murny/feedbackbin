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
      request = ActionDispatch::Request.new(env)

      # Check if account prefix is already in SCRIPT_NAME (e.g., ActionCable reconnection)
      if request.script_name.present? && (match = SLUG_PATTERN.match(request.script_name))
        env["feedbackbin.external_account_id"] = match[1].to_i
      elsif (match = SLUG_PATTERN.match(request.path_info))
        # Normal case: extract account prefix from PATH_INFO and move to SCRIPT_NAME
        external_account_id = match[1].to_i
        remaining_path = match[2].presence || "/"

        request.engine_script_name = request.script_name = AccountSlug.encode(external_account_id)
        request.path_info = remaining_path
        env["feedbackbin.external_account_id"] = external_account_id
      end

      if env["feedbackbin.external_account_id"]
        account = Account.find_by(external_account_id: env["feedbackbin.external_account_id"])
        Current.with_account(account) { @app.call(env) }
      else
        Current.without_account { @app.call(env) }
      end
    end
  end
end

# Insert middleware early in stack, after TempfileReaper
# Current.with_account blocks wrap the entire request lifecycle
Rails.application.config.middleware.insert_after Rack::TempfileReaper, AccountSlug::Extractor
