# frozen_string_literal: true

require "test_helper"
require "rails-dom-testing"

class FormBuilders::TailwindFormBuilderTest < ActionView::TestCase
  include ActionView::Helpers::FormHelper
  include InlineSvg::ActionView::Helpers

  setup do
    @form_object = User.new
  end

  test "text_field returns tailwind styled text field" do
    form = FormBuilders::TailwindFormBuilder.new(:user, @form_object, self, {})

    expected = %(<div class="mt-2 relative rounded-md shadow-sm">
      <input
        class="block w-full rounded-md border-0 py-1.5 shadow-sm sm:text-sm sm:leading-6 ring-1 ring-inset focus:ring-2 focus:ring-inset focus:ring-primary-600 dark:focus:ring-primary-500 dark:bg-white/5 text-gray-900 dark:text-white ring-gray-300 dark:ring-white/10 placeholder:text-gray-400 dark:placeholder:text-gray-500"
        type="text"
        name="user[name]"
        id="user_name" />
    </div>)

    assert_dom_equal expected, form.text_field(:name)
  end

  test "text_field with leading icon returns tailwind styled text field" do
    form = FormBuilders::TailwindFormBuilder.new(:user, @form_object, self, {})

    expected = %(<div class="mt-2 relative rounded-md shadow-sm">
      <div>{class: &quot;pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3&quot;}</div>
      <input leading_icon="true"
             class="block w-full rounded-md border-0 py-1.5 shadow-sm sm:text-sm sm:leading-6 ring-1 ring-inset focus:ring-2 focus:ring-inset focus:ring-primary-600 dark:focus:ring-primary-500 dark:bg-white/5 text-gray-900 dark:text-white ring-gray-300 dark:ring-white/10 placeholder:text-gray-400 dark:placeholder:text-gray-500 pl-10"
             type="text"
             name="user[username]"
             id="user_username" />
    </div>)

    assert_dom_equal expected, form.text_field(:username, leading_icon: true)
  end

  test "text_field with classes returns tailwind styled text field with additional classes" do
    form = FormBuilders::TailwindFormBuilder.new(:user, @form_object, self, {})

    expected = %(<div class="mt-2 relative rounded-md shadow-sm">
      <input
        class="block w-full rounded-md border-0 py-1.5 shadow-sm sm:text-sm sm:leading-6 ring-1 ring-inset focus:ring-2 focus:ring-inset focus:ring-primary-600 dark:focus:ring-primary-500 dark:bg-white/5 text-gray-900 dark:text-white ring-gray-300 dark:ring-white/10 placeholder:text-gray-400 dark:placeholder:text-gray-500 test-class"
        type="text"
        name="user[username]"
        id="user_username" />
    </div>)

    assert_dom_equal expected, form.text_field(:username, class: "test-class")
  end

  test "text_field with errors returns tailwind styled text field" do
    @form_object.errors.add(:username, "must be present")
    @form_object.errors.add(:username, "must be unique")
    @form_object.errors.add(:username, "must be at least three characters")

    form = FormBuilders::TailwindFormBuilder.new(:user, @form_object, self, {})
    field_html = form.text_field(:username)

    assert_match(/Must be present, must be unique, and must be at least three characters/, field_html)
    assert_match(/border-red-500/, field_html)
    assert_match(/bg-red-50/, field_html)
    assert_match(/text-red-900/, field_html)
  end

  test "text_field with no object returns tailwind styled text field" do
    form = FormBuilders::TailwindFormBuilder.new(:user, nil, self, {})

    expected = %(<div class="mt-2 relative rounded-md shadow-sm">
      <input
        class="block w-full rounded-md border-0 py-1.5 shadow-sm sm:text-sm sm:leading-6 ring-1 ring-inset focus:ring-2 focus:ring-inset focus:ring-primary-600 dark:focus:ring-primary-500 dark:bg-white/5 text-gray-900 dark:text-white ring-gray-300 dark:ring-white/10 placeholder:text-gray-400 dark:placeholder:text-gray-500"
        type="text"
        name="user[name]"
        id="user_name" />
    </div>)

    assert_dom_equal expected, form.text_field(:name)
  end

  test "email_field returns tailwind styled email field" do
    form = FormBuilders::TailwindFormBuilder.new(:user, @form_object, self, {})

    expected = %(<div class="mt-2 relative rounded-md shadow-sm">
      <input
        class="block w-full rounded-md border-0 py-1.5 shadow-sm sm:text-sm sm:leading-6 ring-1 ring-inset focus:ring-2 focus:ring-inset focus:ring-primary-600 dark:focus:ring-primary-500 dark:bg-white/5 text-gray-900 dark:text-white ring-gray-300 dark:ring-white/10 placeholder:text-gray-400 dark:placeholder:text-gray-500"
        type="email"
        name="user[email_address]"
        id="user_email_address" />
    </div>)

    assert_dom_equal expected, form.email_field(:email_address)
  end

  test "date_field returns tailwind styled date field" do
    form = FormBuilders::TailwindFormBuilder.new(:user, @form_object, self, {})

    expected = %(<div class="mt-2 relative rounded-md shadow-sm">
      <input
        class="block w-full rounded-md border-0 py-1.5 shadow-sm sm:text-sm sm:leading-6 ring-1 ring-inset focus:ring-2 focus:ring-inset focus:ring-primary-600 dark:focus:ring-primary-500 dark:bg-white/5 text-gray-900 dark:text-white ring-gray-300 dark:ring-white/10 placeholder:text-gray-400 dark:placeholder:text-gray-500"
        type="date"
        name="user[created_at]"
        id="user_created_at" />
    </div>)

    assert_dom_equal expected, form.date_field(:created_at)
  end

  test "password_field returns tailwind styled password field" do
    form = FormBuilders::TailwindFormBuilder.new(:user, @form_object, self, {})

    expected = %(<div class="mt-2 relative rounded-md shadow-sm">
      <input
        class="block w-full rounded-md border-0 py-1.5 shadow-sm sm:text-sm sm:leading-6 ring-1 ring-inset focus:ring-2 focus:ring-inset focus:ring-primary-600 dark:focus:ring-primary-500 dark:bg-white/5 text-gray-900 dark:text-white ring-gray-300 dark:ring-white/10 placeholder:text-gray-400 dark:placeholder:text-gray-500"
        type="password"
        name="user[password]"
        id="user_password" />
    </div>)

    assert_dom_equal expected, form.password_field(:password)
  end

  test "text_area returns tailwind styled text area" do
    form = FormBuilders::TailwindFormBuilder.new(:user, @form_object, self, {})

    expected = %(
    <div class="mt-2 relative rounded-md shadow-sm">
      <textarea class="mt-1 block w-full rounded-md border-0 py-1.5 shadow-sm sm:text-sm sm:leading-6 ring-1 ring-inset focus:ring-2 focus:ring-inset focus:ring-primary-600 dark:focus:ring-primary-500 dark:bg-white/5 text-gray-900 dark:text-white ring-gray-300 dark:ring-white/10 placeholder:text-gray-400 dark:placeholder:text-gray-500"
      name="user[bio]"
      id="user_bio"></textarea>
    </div>)

    assert_dom_equal expected, form.text_area(:bio)
  end

  test "select returns tailwind styled select" do
    form = FormBuilders::TailwindFormBuilder.new(:user, @form_object, self, {})

    expected = %(<select
      class="block w-full mt-6 sm:mt-0 border rounded-md py-2 px-3 focus:outline-none dark:bg-gray-700/50 dark:border-gray-500 dark:text-gray-300 dark:placeholder-gray-400 dark:focus:ring-2 dark:focus:border-transparent border-gray-300 focus:ring-primary-600 focus:border-primary-600 dark:focus:ring-primary-400"
      name="user[active]"
      id="user_active"></select>)

    assert_dom_equal expected, form.select(:active, [])
  end

  test "check_box returns tailwind styled check box" do
    form = FormBuilders::TailwindFormBuilder.new(:user, @form_object, self, {})

    expected = %(<input name="user[active]" type="hidden" value="0" autocomplete="off" />
    <input class="h-4 w-4 border-gray-300 rounded"
           type="checkbox" value="1" checked="checked" name="user[active]" id="user_active" />)

    assert_dom_equal expected, form.check_box(:active)
  end

  test "label returns tailwind styled label" do
    form = FormBuilders::TailwindFormBuilder.new(:user, @form_object, self, {})

    expected = %(<label class="block text-sm font-medium leading-6 text-gray-900 dark:text-white" for="user_name">Name</label>)

    assert_dom_equal expected, form.label(:name, "Name")
  end

  test "submit" do
    form = FormBuilders::TailwindFormBuilder.new(:user, @form_object, self, {})

    expected = %(<input type="submit" name="commit" value="Create User" class="btn btn-primary" data-disable-with="Create User" />)

    assert_dom_equal expected, form.submit("Create User")
  end
end
