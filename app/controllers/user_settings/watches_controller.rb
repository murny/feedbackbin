# frozen_string_literal: true

module UserSettings
  class WatchesController < ApplicationController
    def index
      @watches = Current.user.watches.watching.includes(:idea).order(created_at: :desc)
    end

    def destroy
      @watch = Current.user.watches.find(params[:id])
      @watch.update!(watching: false)
      @idea = @watch.idea

      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = t("user_settings.watches.show.unwatch_success", title: @idea.title)
        end
        format.html do
          redirect_to user_settings_watches_path,
                      notice: t("user_settings.watches.show.unwatch_success", title: @idea.title)
        end
      end
    end

    def bulk
      Current.user.watches.watching.transaction do
        @count = Current.user.watches.watching.update_all(watching: false)
      end

      redirect_to user_settings_watches_path,
                  notice: t("user_settings.watches.show.bulk_success", count: @count)
    end
  end
end
