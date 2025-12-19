# frozen_string_literal: true

require "test_helper"

module Admin
  module Settings
    class BoardsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:shane)
        @board = boards(:one)
        sign_in_as @admin
      end

      test "should get index" do
        get admin_settings_boards_url

        assert_response :success
      end

      test "should not get index if not an admin" do
        sign_in_as users(:john)

        get admin_settings_boards_url

        assert_response :redirect
        assert_equal I18n.t("unauthorized"), flash[:alert]
      end

      test "should get new" do
        get new_admin_settings_board_url

        assert_response :success
      end

      test "should create board" do
        assert_difference "Board.count", 1 do
          post admin_settings_boards_url, params: {
            board: {
              name: "Documentation",
              description: "Documentation improvements and requests",
              color: "#ff5733"
            }
          }
        end

        assert_redirected_to admin_settings_boards_path
        assert_equal "Board was successfully created.", flash[:notice]
      end

      test "renders 422 on invalid create" do
        assert_no_difference "Board.count" do
          post admin_settings_boards_url, params: {
            board: {
              name: "",
              color: ""
            }
          }
        end

        assert_response :unprocessable_entity
      end

      test "should get edit" do
        get edit_admin_settings_board_url(@board)

        assert_response :success
      end

      test "should update board" do
        patch admin_settings_board_url(@board), params: {
          board: {
            name: "Updated Board Name",
            description: "Updated description",
            color: "#00ff00"
          }
        }

        assert_redirected_to admin_settings_boards_path
        assert_equal "Updated Board Name", @board.reload.name
        assert_equal "Updated description", @board.description
        assert_equal "#00ff00", @board.color
      end

      test "renders 422 on invalid update" do
        patch admin_settings_board_url(@board), params: {
          board: {
            color: "invalid"
          }
        }

        assert_response :unprocessable_entity
      end

      test "should destroy board without ideas" do
        # Create a new board with no ideas
        board_to_delete = Board.create!(
          name: "Temporary Board",
          description: "To be deleted",
          color: "#cccccc"
        )

        assert_difference "Board.count", -1 do
          delete admin_settings_board_url(board_to_delete)
        end

        assert_redirected_to admin_settings_boards_path
        assert_equal "Board was successfully deleted.", flash[:notice]
      end

      test "should not destroy board with ideas" do
        # Create an idea for the board
        Idea.create!(
          title: "Test Idea",
          board: @board,
          creator: @admin,
          status: statuses(:planned)
        )

        assert_predicate @board.ideas, :any?

        assert_no_difference "Board.count" do
          delete admin_settings_board_url(@board)
        end

        assert_redirected_to admin_settings_boards_path
        assert_match(/cannot delete/i, flash[:alert])
      end
    end
  end
end
