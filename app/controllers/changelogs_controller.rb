# frozen_string_literal: true

class ChangelogsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :mark_as_read, if: :authenticated?

  def index
    @pagy, @changelogs = pagy(Changelog.published.order(published_at: :desc))
  end

  def show
    @changelog = Changelog.published.find(params[:id])
  end

  private

    def mark_as_read
      Current.user.update(changelogs_read_at: Time.current)
    end
end
