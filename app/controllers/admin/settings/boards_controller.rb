# frozen_string_literal: true

module Admin
  module Settings
    class BoardsController < Admin::BaseController
      before_action :set_board, only: [ :edit, :update, :destroy ]

      def index
        @boards = Board.includes(:ideas).ordered
      end

      def new
        @board = Board.new
      end

      def create
        @board = Board.new(board_params)

        if @board.save
          redirect_to admin_settings_boards_path, notice: t(".successfully_created")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
      end

      def update
        if @board.update(board_params)
          redirect_to admin_settings_boards_path, notice: t(".successfully_updated")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        if @board.destroy
          redirect_to admin_settings_boards_path, notice: t(".successfully_destroyed")
        else
          redirect_to admin_settings_boards_path, alert: @board.errors.full_messages.to_sentence
        end
      end

      private

        def set_board
          @board = Board.find(params[:id])
        end

        def board_params
          params.require(:board).permit(:name, :description, :color)
        end
    end
  end
end
