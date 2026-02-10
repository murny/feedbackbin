# frozen_string_literal: true

require "test_helper"
require "rails-dom-testing"

module FormBuilders
  class CustomFormBuilderTest < ActionView::TestCase
    include ActionView::Helpers::FormHelper
    include LucideRails::RailsHelper

    class FormObject
      include ActiveModel::Model
      attr_accessor :name, :email_address, :created_at, :password, :bio, :active
    end

    setup do
      @form_object = FormObject.new
    end

    test "text_field returns custom styled text field" do
      form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

      expected = %(<div class="position-relative grid gap-half" data-slot="form-item">
      <input
        class=""
        type="text"
        name="user[name]"
        id="user_name" />
    </div>)

      assert_dom_equal expected, form.text_field(:name)
    end

    test "text_field with leading icon returns custom styled text field" do
      form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

      expected = %(<div class="position-relative grid gap-half" data-slot="form-item">
      <div>{class: &quot;flex align-center&quot;, style: &quot;pointer-events: none; position: absolute; inset-block: 0; inset-inline-start: 0; padding-inline-start: 0.75rem;&quot;}</div>
      <input leading_icon="true"
             class=""
             style="padding-inline-start: 2.5rem;"
             type="text"
             name="user[name]"
             id="user_name" />
    </div>)

      assert_dom_equal expected, form.text_field(:name, leading_icon: true)
    end

    test "text_field with classes returns custom styled text field with additional classes" do
      form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

      expected = %(<div class="position-relative grid gap-half" data-slot="form-item">
      <input
        class="test-class"
        type="text"
        name="user[name]"
        id="user_name" />
    </div>)

      assert_dom_equal expected, form.text_field(:name, class: "test-class")
    end

    test "text_field with errors returns custom styled text field with error classes" do
      @form_object.errors.add(:name, "must be present")
      @form_object.errors.add(:name, "must be at least 3 characters")
      @form_object.errors.add(:name, "must be at most 255 characters")

      form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})
      field_html = form.text_field(:name)

      assert_match(/Must be present, must be at least 3 characters, and must be at most 255 characters/, field_html)
      assert_match(/txt-negative/, field_html)
      assert_match(/position-relative grid gap-half/, field_html)
      assert_match(/<svg.*?class=".*?size-5 txt-negative.*?".*?>/m, field_html)
    end

    test "text_field with no object returns custom styled text field" do
      form = FormBuilders::CustomFormBuilder.new(:user, nil, self, {})

      expected = %(<div class="position-relative grid gap-half" data-slot="form-item">
      <input
        class=""
        type="text"
        name="user[name]"
        id="user_name" />
    </div>)

      assert_dom_equal expected, form.text_field(:name)
    end

    test "email_field returns custom styled email field" do
      form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

      expected = %(<div class="position-relative grid gap-half" data-slot="form-item">
      <input
        class=""
        type="email"
        name="user[email_address]"
        id="user_email_address" />
    </div>)

      assert_dom_equal expected, form.email_field(:email_address)
    end

    test "date_field returns custom styled date field" do
      form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

      expected = %(<div class="position-relative grid gap-half" data-slot="form-item">
      <input
        class=""
        type="date"
        name="user[created_at]"
        id="user_created_at" />
    </div>)

      assert_dom_equal expected, form.date_field(:created_at)
    end

    test "password_field returns custom styled password field" do
      form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

      expected = %(<div class="position-relative grid gap-half" data-slot="form-item">
      <input
        class=""
        type="password"
        name="user[password]"
        id="user_password" />
    </div>)

      assert_dom_equal expected, form.password_field(:password)
    end

    test "text_area returns custom styled text area" do
      form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

      expected = %(
    <div class="position-relative grid gap-half" data-slot="form-item">
      <textarea class=""
      name="user[bio]"
      id="user_bio"></textarea>
    </div>)

      assert_dom_equal expected, form.text_area(:bio)
    end

    test "select returns custom styled select" do
      form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

      expected = %(<select
      class=""
      name="user[active]"
      id="user_active"></select>)

      assert_dom_equal expected, form.select(:active, [])
    end

    test "check_box returns custom styled check box" do
      form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

      expected = %(<input name="user[active]" type="hidden" value="0" />
    <input class=""
           type="checkbox" value="1" name="user[active]" id="user_active" />)

      assert_dom_equal expected, form.check_box(:active)
    end

    test "label returns custom styled label" do
      form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

      expected = %(<label class="" for="user_name">Name</label>)

      assert_dom_equal expected, form.label(:name, "Name")
    end

    test "submit returns custom styled submit button" do
      form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

      expected = %(<input type="submit" name="commit" value="Create User" class="btn btn--primary" data-disable-with="Create User" />)

      assert_dom_equal expected, form.submit("Create User")
    end
  end
end
