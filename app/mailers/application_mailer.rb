# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "FeedbackBin <support@feedbackbin.com>")
  layout "mailer"
  helper :application

  private

    def set_unwatch_headers(idea, recipient)
      if token = view_context.unwatch_token_for(idea, recipient)
        headers["List-Unsubscribe"] = "<#{unsubscribe_destroy_by_token_url(token: token)}>"
        headers["List-Unsubscribe-Post"] = "List-Unsubscribe=One-Click"
      end
    end

    def default_url_options
      if Current.account
        super.merge(script_name: Current.account.slug)
      else
        super
      end
    end
end
