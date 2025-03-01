module Admin
  module Docs
    class ComponentsController < Admin::BaseController
      def show
        @component = params[:id]

        render "admin/docs/components/#{@component}"
      end
    end
  end
end
