# frozen_string_literal: true

module Admin
  module Settings
    class CategoriesController < Admin::BaseController
      before_action :set_category, only: [ :edit, :update, :destroy ]

      def index
        @categories = Category.includes(:posts).ordered
      end

      def new
        @category = Category.new
      end

      def create
        @category = Category.new(category_params)

        if @category.save
          redirect_to admin_settings_categories_path, notice: t(".successfully_created")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
      end

      def update
        if @category.update(category_params)
          redirect_to admin_settings_categories_path, notice: t(".successfully_updated")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        if @category.destroy
          redirect_to admin_settings_categories_path, notice: t(".successfully_destroyed")
        else
          redirect_to admin_settings_categories_path, alert: @category.errors.full_messages.to_sentence
        end
      end

      private

        def set_category
          @category = Category.find(params[:id])
        end

        def category_params
          params.require(:category).permit(:name, :description, :color)
        end
    end
  end
end
