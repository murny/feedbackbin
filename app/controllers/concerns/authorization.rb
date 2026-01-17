# frozen_string_literal: true

module Authorization
  # Adds authorization with Pundit to controllers

  extend ActiveSupport::Concern
  include Pundit::Authorization

  included do
    after_action :verify_authorized
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  end

  def pundit_user
    Current.user
  end

  private

    # You can also customize the messages using the policy and action to generate the I18n key
    # https://github.com/varvet/pundit#creating-custom-error-messages
    def user_not_authorized
      if authenticated_but_not_member?
        # User is logged in but not a member of this account - prompt to join
        redirect_to users_sign_up_path, alert: t("authorization.join_to_participate")
      else
        redirect_back_or_to root_path, alert: t("authorization.unauthorized")
      end
    end

    # Check if user has a valid session/identity but no User record for current account
    def authenticated_but_not_member?
      Current.account.present? && Current.identity.present? && Current.user.nil?
    end
end
