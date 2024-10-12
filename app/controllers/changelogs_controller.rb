class ChangelogsController < ApplicationController
  before_action :mark_as_read, if: :authenticated?

  def index
    @pagy, @changelogs = pagy(Changelog.order(published_at: :desc))
  end

  def show
    @changelog = Changelog.find(params[:id])
  end

  private

  def mark_as_read
    Current.user.update(changelogs_read_at: Time.zone.now)
  end
end
