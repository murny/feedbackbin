# frozen_string_literal: true

module Staff
  class AccountsController < Staff::BaseController
    def index
      accounts = Account.search(params[:search])
                        .order(created_at: :desc)

      @pagy, @accounts = pagy(accounts)

      respond_to do |format|
        format.html
        format.turbo_stream { render "index" }
      end
    end

    def show
      @account = Account.find(params[:id])
    end
  end
end
