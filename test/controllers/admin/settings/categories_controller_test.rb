# frozen_string_literal: true

require "test_helper"

module Admin
  module Settings
    class CategoriesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:shane)
        @category = categories(:one)
        sign_in_as @admin
      end

      test "should get index" do
        get admin_settings_categories_url

        assert_response :success
      end

      test "should not get index if not an admin" do
        sign_in_as users(:two)

        get admin_settings_categories_url

        assert_response :redirect
        assert_equal I18n.t("unauthorized"), flash[:alert]
      end

      test "should get new" do
        get new_admin_settings_category_url

        assert_response :success
      end

      test "should create category" do
        assert_difference "Category.count", 1 do
          post admin_settings_categories_url, params: {
            category: {
              name: "Documentation",
              description: "Documentation improvements and requests",
              color: "#ff5733"
            }
          }
        end

        assert_redirected_to admin_settings_categories_path
        assert_equal "Category was successfully created.", flash[:notice]
      end

      test "renders 422 on invalid create" do
        assert_no_difference "Category.count" do
          post admin_settings_categories_url, params: {
            category: {
              name: "",
              color: ""
            }
          }
        end

        assert_response :unprocessable_entity
      end

      test "should get edit" do
        get edit_admin_settings_category_url(@category)

        assert_response :success
      end

      test "should update category" do
        patch admin_settings_category_url(@category), params: {
          category: {
            name: "Updated Category Name",
            description: "Updated description",
            color: "#00ff00"
          }
        }

        assert_redirected_to admin_settings_categories_path
        assert_equal "Updated Category Name", @category.reload.name
        assert_equal "Updated description", @category.description
        assert_equal "#00ff00", @category.color
      end

      test "renders 422 on invalid update" do
        patch admin_settings_category_url(@category), params: {
          category: {
            color: "invalid"
          }
        }

        assert_response :unprocessable_entity
      end

      test "should destroy category without posts" do
        # Create a new category with no posts
        category_to_delete = Category.create!(
          name: "Temporary Category",
          description: "To be deleted",
          color: "#cccccc"
        )

        assert_difference "Category.count", -1 do
          delete admin_settings_category_url(category_to_delete)
        end

        assert_redirected_to admin_settings_categories_path
        assert_equal "Category was successfully deleted.", flash[:notice]
      end

      test "should not destroy category with posts" do
        # Create a post for the category
        Post.create!(
          title: "Test Post",
          category: @category,
          author: @admin,
          post_status: post_statuses(:planned)
        )

        assert_predicate @category.posts, :any?

        assert_no_difference "Category.count" do
          delete admin_settings_category_url(@category)
        end

        assert_redirected_to admin_settings_categories_path
        assert_match(/cannot delete/i, flash[:alert])
      end
    end
  end
end
