# frozen_string_literal: true

# # frozen_string_literal: true

# require "test_helper"

# class PasswordsControllerTest < ActionDispatch::IntegrationTest
#   setup do
#     sign_in(users(:shane))
#   end

#   test "should get edit" do
#     get edit_password_url

#     assert_response :success
#   end

#   test "should update password" do
#     patch password_url, params: {token: "123456", password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*"}

#     assert_redirected_to user_dashboard_path
#   end

#   test "should not update password with wrong token" do
#     patch password_url, params: {token: "SecretWrong1*3", password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*"}

#     assert_response :unprocessable_entity
#     assert_select "li", /#{I18n.t("activerecord.errors.models.user.attributes.password_challenge.invalid")}/
#   end
# end
