# frozen_string_literal: true

module Admin
  module Settings
    class DangerZonesController < Admin::BaseController
      before_action :ensure_owner

      def show
        @owner = User.owner.first
      end

      def destroy
        name_confirmation = params.dig(:account, :name).to_s.strip
        acknowledged = ActiveModel::Type::Boolean.new.cast(params.dig(:account, :acknowledge))

        if name_confirmation != Current.account.name
          @owner = User.owner.first
          flash.now[:alert] = t(".name_confirmation_mismatch")
          return render :show, status: :unprocessable_entity
        end

        unless acknowledged
          @owner = User.owner.first
          flash.now[:alert] = t(".acknowledgment_required")
          return render :show, status: :unprocessable_entity
        end

        Account.transaction do
          Current.account.destroy!
        end

        reset_session

        # TODO: This won't be root_path in the future but marketing site?
        redirect_to root_path, notice: t(".success")
      end
    end
  end
end
