# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  included do
    before_action :ensure_can_access_account, if: :authenticated_account_access?
  end

  class_methods do
    def allow_unauthorized_access(**options)
      skip_before_action :ensure_can_access_account, **options
    end
  end

  private

    def ensure_admin
      head :forbidden unless Current.user&.admin?
    end

    def ensure_owner
      head :forbidden unless Current.user&.owner?
    end

    def ensure_staff
      head :forbidden unless Current.identity&.staff?
    end

    def authenticated_account_access?
      Current.account.present? && authenticated?
    end

    def ensure_can_access_account
      if !Current.account.active?
        message = I18n.t("authorization.account_inactive")
      elsif Current.user.present? && !Current.user.active?
        message = I18n.t("authorization.user_inactive")
      end

      if message
        respond_to do |format|
          format.html { redirect_to session_menu_path(script_name: nil), alert: message }
          format.json { head :forbidden }
        end
      end
    end
end
