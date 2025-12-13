# frozen_string_literal: true

class AccountsController < ApplicationController
  skip_after_action :verify_authorized

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)

    ApplicationRecord.transaction do
      @account.save!

      statuses = [
        Status.create!(name: "Open", color: "#3b82f6", position: 1, account: @account),
        Status.create!(name: "Planned", color: "#8b5cf6", position: 2, account: @account),
        Status.create!(name: "In Progress", color: "#f59e0b", position: 3, account: @account),
        Status.create!(name: "Complete", color: "#10b981", position: 4, account: @account),
        Status.create!(name: "Closed", color: "#ef4444", position: 5, account: @account)
      ]

      @account.update!(default_status: statuses.first)

      user = Current.identity.users.create!(
        account: @account,
        name: params.dig(:user, :name).presence || Current.identity.email_address.split("@").first,
        role: :owner,
        email_verified: true
      )

      Current.session.update!(current_account: @account)
      redirect_to root_path, notice: t(".created_successfully", name: user.name)
    end
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

    def account_params
      params.expect(account: [ :name, :subdomain ])
    end
end
