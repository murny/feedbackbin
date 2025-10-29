# frozen_string_literal: true

module Admin
  module Users
    class RolesController < Admin::BaseController
      before_action :set_user

      # PATCH /admin/users/:user_id/role
      def update
        role = params.expect(:role)

        unless User.roles.key?(role)
          flash.now[:alert] = t(".invalid_role")
          respond_to do |format|
            format.html { redirect_to admin_user_path(@user) }
            format.turbo_stream { render :update, status: :unprocessable_entity }
          end
          return
        end

        respond_to do |format|
          if @user.update(role: role)
            flash.now[:notice] = t(".success")
            format.html { redirect_to admin_user_path(@user), notice: t(".success") }
            format.turbo_stream
          else
            flash.now[:alert] = @user.errors.full_messages.to_sentence
            format.html { redirect_to admin_user_path(@user), alert: @user.errors.full_messages.to_sentence }
            format.turbo_stream { render :update, status: :unprocessable_entity }
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
