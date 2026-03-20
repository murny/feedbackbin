# frozen_string_literal: true

module Admin
  class ChangelogsController < Admin::BaseController
    before_action :set_changelog, only: [ :edit, :update, :destroy ]

    def index
      @pagy, @changelogs = pagy(Changelog.order(updated_at: :desc))
    end

    def new
      @changelog = Changelog.new
    end

    def create
      @changelog = Changelog.new(changelog_params)
      @changelog.published_at = Time.current if publish_requested?

      if @changelog.save
        redirect_to admin_changelogs_path, notice: t(".successfully_created"), status: :see_other
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @changelog.assign_attributes(changelog_params)

      if publish_requested?
        @changelog.published_at ||= Time.current
      else
        @changelog.published_at = nil
      end

      if @changelog.save
        redirect_to admin_changelogs_path, notice: t(".successfully_updated"), status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @changelog.destroy
      redirect_to admin_changelogs_path, notice: t(".successfully_destroyed"), status: :see_other
    end

    private

      def set_changelog
        @changelog = Changelog.find(params[:id])
      end

      def changelog_params
        params.require(:changelog).permit(:title, :description, :kind)
      end

      def publish_requested?
        params.dig(:changelog, :publish) == "1"
      end
  end
end
