# frozen_string_literal: true

module Admin
  module Users
    class RolesController < Admin::BaseController
      before_action :set_user

      # PATCH /admin/users/:user_id/role
      def update
        role = params.expect(:role)

        respond_to do |format|
          if !User.roles.key?(role)
            format.html { redirect_to admin_user_path(@user), alert: t(".invalid_role") }
            format.turbo_stream do
              flash.now[:alert] = t(".invalid_role")
              render :update, status: :unprocessable_entity
            end
          elsif @user.update(role: role)
            format.html { redirect_to admin_user_path(@user), notice: t(".success") }
            format.turbo_stream do
              flash.now[:notice] = t(".success")
            end
          else
            format.html { redirect_to admin_user_path(@user), alert: @user.errors.full_messages.to_sentence }
            format.turbo_stream do
              flash.now[:alert] = @user.errors.full_messages.to_sentence
              render :update, status: :unprocessable_entity
            end
          end
        end
      end

      private

        def set_user
          @user = User.find(params.expect(:user_id))
        end
    end
  end
end
