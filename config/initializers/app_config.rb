# frozen_string_literal: true

Rails.application.config.app_version = ENV.fetch("APP_VERSION", "0")
Rails.application.config.git_revision = ENV["GIT_REVISION"]
Rails.application.config.app_mode = ((ENV["SELF_HOSTED"] == "true") ? "self_hosted" : "managed").inquiry
Rails.application.config.app_name = "FeedbackBin"
