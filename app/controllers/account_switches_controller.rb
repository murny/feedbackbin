# frozen_string_literal: true

class AccountSwitchesController < ApplicationController
  skip_after_action :verify_authorized

  def update
    account = Current.identity.accounts.find(params[:account_id])
    Current.session.switch_account!(account)
    redirect_to root_path, notice: t(".switched_to", name: account.name)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t(".account_not_found")
  end
end
