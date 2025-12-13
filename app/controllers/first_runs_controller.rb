# frozen_string_literal: true

class FirstRunsController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :ensure_first_run_completed
  skip_after_action :verify_authorized

  before_action :prevent_repeats

  def show
    @first_run = FirstRun.new
  end

  def create
    @first_run = FirstRun.new(first_run_params).save!
    start_new_session_for @first_run.identity, account: @first_run.account
    redirect_to root_path, notice: t(".account_created")
  rescue ActiveModel::ValidationError => e
    @first_run = e.model
    render :show, status: :unprocessable_entity
  end

  private

    def prevent_repeats
      redirect_to root_path if Account.any?
    end

    def first_run_params
      params.expect(first_run: [
        :name, :avatar, :email_address, :password,
        :account_name, :account_subdomain, :account_logo,
        :board_name, :board_color
      ])
    end
end
