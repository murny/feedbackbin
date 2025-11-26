# frozen_string_literal: true

class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    if Current.organization
      redirect_to Current.organization.root_path_url, allow_other_host: false
    else
      # If no organization exists, redirect to first run
      redirect_to first_run_path
    end
  end
end
