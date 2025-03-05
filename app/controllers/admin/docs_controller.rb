# frozen_string_literal: true

module Admin
  class DocsController < Admin::BaseController
    def index
    end

    def show
      @document = params[:id]

      render "admin/docs/#{@document}"
    end
  end
end
