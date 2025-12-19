# frozen_string_literal: true

module Admin
  module Users
    class ActivationsController < Admin::BaseController
      before_action :set_user

      # POST /admin/users/:user_id/activation
      def create
        respond_to do |format|
          if @user.update(active: true)
            format.html { redirect_to admin_user_path(@user), notice: t(".success") }
            format.turbo_stream do
              flash.now[:notice] = t(".success")
            end
          else
            format.html { redirect_to admin_user_path(@user), alert: @user.errors.full_messages.to_sentence }
            format.turbo_stream do
              flash.now[:alert] = @user.errors.full_messages.to_sentence
              render :create, status: :unprocessable_entity
            end
          end
        end
      end

      # DELETE /admin/users/:user_id/activation
      def destroy
        @user.deactivate
        respond_to do |format|
          format.html { redirect_to admin_user_path(@user), notice: t(".success") }
          format.turbo_stream { flash.now[:notice] = t(".success") }
        end
      rescue ActiveRecord::RecordInvalid
        respond_to do |format|
          format.html { redirect_to admin_user_path(@user), alert: @user.errors.full_messages.to_sentence }
          format.turbo_stream do
            flash.now[:alert] = @user.errors.full_messages.to_sentence
            render :destroy, status: :unprocessable_entity
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
