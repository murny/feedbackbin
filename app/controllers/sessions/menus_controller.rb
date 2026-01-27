# frozen_string_literal: true

class Sessions::MenusController < ApplicationController
  include AuthLayout

  disallow_account_scope

  def show
    @accounts = Current.identity.accounts

    if @accounts.one?
      redirect_to root_url(script_name: @accounts.first.slug)
    end
  end
end
