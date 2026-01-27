# frozen_string_literal: true

# Invitations controller - displays invitation to join an account.
# Works in the context of the invitation's account, not a URL-based tenant.
# The invitation itself determines the account context.
class InvitationsController < ApplicationController
  allow_unauthenticated_access

  skip_before_action :require_account
  skip_before_action :ensure_account_user

  before_action :set_invitation
  before_action :set_account_from_invitation

  rate_limit to: 10, within: 1.minute, only: :show, with: -> { redirect_to root_path, alert: t("invitations.show.rate_limited") }

  def show
  end

  private

    def set_invitation
      @invitation = Invitation.find_by!(token: params[:token])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: t("invitations.show.not_found")
    end

    def set_account_from_invitation
      Current.account = @invitation.account
    end
end
