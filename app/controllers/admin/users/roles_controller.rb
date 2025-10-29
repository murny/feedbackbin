# frozen_string_literal: true

module Admin
  module Users
    class RolesController < Admin::BaseController
      before_action :set_user

      # PATCH /admin/users/:user_id/role
      def update
        role = params.expect(:role)

        unless User.roles.key?(role)
          return redirect_to admin_user_path(@user), alert: t(".invalid_role")
        end

        if @user.update(role: role)
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
