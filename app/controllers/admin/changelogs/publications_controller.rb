# frozen_string_literal: true

module Admin
  module Changelogs
    class PublicationsController < Admin::BaseController
      before_action :set_changelog

      def create
        @changelog.update!(published_at: Time.current)
        redirect_to admin_changelogs_path, notice: t(".successfully_published"), status: :see_other
      end

      def destroy
        @changelog.update!(published_at: nil)
        redirect_to admin_changelogs_path, notice: t(".successfully_unpublished"), status: :see_other
      end

      private

        def set_changelog
          @changelog = Current.account.changelogs.find(params[:changelog_id])
        end
    end
  end
end
