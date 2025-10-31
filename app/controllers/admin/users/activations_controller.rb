# frozen_string_literal: true

module Admin
  module Users
    class ActivationsController < Admin::BaseController
      before_action :set_user

      # POST /admin/users/:user_id/activation
      def create
        respond_to do |format|
          if @user.update(active: true)
            flash.now[:notice] = t(".success")
            format.html { redirect_to admin_user_path(@user), notice: t(".success") }
            format.turbo_stream
          else
            flash.now[:alert] = @user.errors.full_messages.to_sentence
            format.html { redirect_to admin_user_path(@user), alert: @user.errors.full_messages.to_sentence }
            format.turbo_stream { render :create, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /admin/users/:user_id/activation
      def destroy
        respond_to do |format|
          if @user.deactivate
            flash.now[:notice] = t(".success")
            format.html { redirect_to admin_user_path(@user), notice: t(".success") }
            format.turbo_stream
          else
            flash.now[:alert] = @user.errors.full_messages.to_sentence
            format.html { redirect_to admin_user_path(@user), alert: @user.errors.full_messages.to_sentence }
            format.turbo_stream { render :destroy, status: :unprocessable_entity }
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
