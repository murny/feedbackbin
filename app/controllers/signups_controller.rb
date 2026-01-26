# frozen_string_literal: true

# Untenanted controller for creating a new Account (tenant).
# This creates both the Account and the owner Identity/User.
# For registering as a User within an existing Account, see Users::RegistrationsController.
class SignupsController < ApplicationController
  include AuthLayout

  disallow_account_scope
  require_unauthenticated_access
  skip_before_action :ensure_signup_completed
  skip_after_action :verify_authorized

  before_action :require_accepting_signups

  def show
    @signup = Signup.new
  end

  def create
    @signup = Signup.new(signup_params).save!
    start_new_session_for @signup.identity
    redirect_to root_url(script_name: @signup.account.slug), notice: t(".account_created")
  rescue ActiveModel::ValidationError => e
    @signup = e.model
    render :show, status: :unprocessable_entity
  end

  private

    def require_accepting_signups
      redirect_to sign_in_path(script_name: nil) unless Account.accepting_signups?
    end

    def signup_params
      params.expect(signup: [
        :name, :avatar, :email_address, :password,
        :account_name, :account_logo
      ])
    end
end
