module Admin
  module Documentation
    class ComponentsController < Admin::BaseController
      def show
        @component = params[:id]

        render "admin/documentation/components/#{@component}"
      end
    end
  end
end
