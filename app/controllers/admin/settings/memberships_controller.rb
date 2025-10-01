# frozen_string_literal: true

class Admin::Settings::MembershipsController < Admin::BaseController
  before_action :set_user, only: [ :destroy ]

  def index
    @admin_users = User.administrator.active.ordered
  end

  def destroy
    if @user.administrator? && User.administrator.count == 1
      redirect_to admin_settings_memberships_path, alert: t(".cannot_remove_last_admin")
    else
      @user.update!(role: :member)
      redirect_to admin_settings_memberships_path, notice: t(".successfully_removed")
    end
  end

  private

    def set_user
      @user = User.find(params[:id])
    end
end
