# frozen_string_literal: true

class FirstRunsController < ApplicationController
  allow_unauthenticated_access
  skip_after_action :verify_authorized

  before_action :prevent_repeats

  def show
    @first_run = FirstRun.new
  end

  def create
    @first_run = FirstRun.create!(first_run_params)
    start_new_session_for @first_run.user
    redirect_to root_path, notice: t(".organization_created")
  rescue ActiveRecord::RecordInvalid => e
    @first_run = e.record
    render :show, status: :unprocessable_entity
  end

  private

    def prevent_repeats
      redirect_to root_path if Organization.any?
    end

    def first_run_params
      params.expect(first_run: [
        :username, :name, :avatar, :email_address, :password,
        :organization_name, :organization_subdomain, :organization_logo,
        :category_name
      ])
    end
end
