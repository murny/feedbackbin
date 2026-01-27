# frozen_string_literal: true

module UserSettings
  class PasswordsController < ApplicationController
    before_action :set_identity

    def show
    end

    def update
      if @identity.update(identity_params)
        redirect_to user_settings_password_path, notice: t(".password_changed")
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

      def identity_params
        params.expect(identity: [ :password, :password_confirmation, :password_challenge ])
      end

      def set_identity
        @identity = Current.identity
      end
  end
end
