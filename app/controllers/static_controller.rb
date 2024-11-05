# frozen_string_literal: true

class StaticController < ApplicationController
  allow_unauthenticated_access
  skip_after_action :verify_authorized

  def about
  end

  def terms
  end

  def privacy
  end
end
