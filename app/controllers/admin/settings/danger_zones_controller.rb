# frozen_string_literal: true

module Admin
  module Settings
    class DangerZonesController < Admin::BaseController
      before_action :ensure_owner

      def show
      end

      def destroy
        name_confirmation = params.dig(:organization, :name).to_s.strip
        acknowledged = ActiveModel::Type::Boolean.new.cast(params.dig(:organization, :acknowledge))

        if name_confirmation != Current.organization.name
          flash.now[:alert] = t(".name_confirmation_mismatch")
          return render :show, status: :unprocessable_entity
        end

        unless acknowledged
          flash.now[:alert] = t(".acknowledgment_required")
          return render :show, status: :unprocessable_entity
        end

        Organization.transaction do
          Current.organization.destroy!
        end

        reset_session

        # TODO: This won't be root_path in the future but marketing site?
        redirect_to root_path, notice: t(".success")
      end

      private

        def ensure_owner
          authorize Current.organization, :destroy?
        end
    end
  end
end
