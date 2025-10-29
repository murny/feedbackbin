# frozen_string_literal: true

module Admin
  module Users
    class ActivationsController < Admin::BaseController
      before_action :set_user

      # POST /admin/users/:user_id/activation
      def create
        if @user.update(active: true)
          redirect_to admin_user_path(@user), notice: t(".success")
        else
          redirect_to admin_user_path(@user), alert: @user.errors.full_messages.to_sentence
        end
      end

      # DELETE /admin/users/:user_id/activation
      def destroy
        if @user.deactivate
          redirect_to admin_user_path(@user), notice: t(".success")
        else
          redirect_to admin_user_path(@user), alert: @user.errors.full_messages.to_sentence
        end
      end

      private

        def set_user
          @user = User.find(params.expect(:user_id))
        end
    end
  end
end
