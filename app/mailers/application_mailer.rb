# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  private

    def default_url_options
      if Current.account
        super.merge(script_name: Current.account.slug)
      else
        super
      end
    end
end
