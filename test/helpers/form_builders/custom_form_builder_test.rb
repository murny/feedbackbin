# frozen_string_literal: true

require "test_helper"
require "rails-dom-testing"

module FormBuilders
  class CustomFormBuilderTest < ActionView::TestCase
    include ActionView::Helpers::FormHelper
  include InlineSvg::ActionView::Helpers

  setup do
    @form_object = User.new
  end

  test "text_field returns shadcn styled text field" do
    form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

    expected = %(<div class="grid gap-2" data-slot="form-item">
      <input
        class="border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 flex w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 dark:bg-input/30 md:text-sm"
        type="text"
        name="user[name]"
        id="user_name" />
    </div>)

    assert_dom_equal expected, form.text_field(:name)
  end

  test "text_field with leading icon returns shadcn styled text field" do
    form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

    expected = %(<div class="grid gap-2" data-slot="form-item">
      <div>{class: &quot;pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3&quot;}</div>
      <input leading_icon="true"
             class="border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 flex w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 dark:bg-input/30 md:text-sm pl-10"
             type="text"
             name="user[username]"
             id="user_username" />
    </div>)

    assert_dom_equal expected, form.text_field(:username, leading_icon: true)
  end

  test "text_field with classes returns shadcn styled text field with additional classes" do
    form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

    expected = %(<div class="grid gap-2" data-slot="form-item">
      <input
        class="border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 flex w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 dark:bg-input/30 md:text-sm test-class"
        type="text"
        name="user[username]"
        id="user_username" />
    </div>)

    assert_dom_equal expected, form.text_field(:username, class: "test-class")
  end

  test "text_field with errors returns shadcn styled text field with error classes" do
    @form_object.errors.add(:username, "must be present")
    @form_object.errors.add(:username, "must be unique")
    @form_object.errors.add(:username, "must be at least three characters")

    form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})
    field_html = form.text_field(:username)

    assert_match(/Must be present, must be unique, and must be at least three characters/, field_html)
    assert_match(/aria-invalid:ring-destructive\/20/, field_html)
    assert_match(/aria-invalid:border-destructive/, field_html)
    assert_match(/text-destructive/, field_html)
  end

  test "text_field with no object returns shadcn styled text field" do
    form = FormBuilders::CustomFormBuilder.new(:user, nil, self, {})

    expected = %(<div class="grid gap-2" data-slot="form-item">
      <input
        class="border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 flex w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 dark:bg-input/30 md:text-sm"
        type="text"
        name="user[name]"
        id="user_name" />
    </div>)

    assert_dom_equal expected, form.text_field(:name)
  end

  test "email_field returns shadcn styled email field" do
    form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

    expected = %(<div class="grid gap-2" data-slot="form-item">
      <input
        class="border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 flex w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 dark:bg-input/30 md:text-sm"
        type="email"
        name="user[email_address]"
        id="user_email_address" />
    </div>)

    assert_dom_equal expected, form.email_field(:email_address)
  end

  test "date_field returns shadcn styled date field" do
    form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

    expected = %(<div class="grid gap-2" data-slot="form-item">
      <input
        class="border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 flex w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 dark:bg-input/30 md:text-sm"
        type="date"
        name="user[created_at]"
        id="user_created_at" />
    </div>)

    assert_dom_equal expected, form.date_field(:created_at)
  end

  test "password_field returns shadcn styled password field" do
    form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

    expected = %(<div class="grid gap-2" data-slot="form-item">
      <input
        class="border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 flex w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 dark:bg-input/30 md:text-sm"
        type="password"
        name="user[password]"
        id="user_password" />
    </div>)

    assert_dom_equal expected, form.password_field(:password)
  end

  test "text_area returns shadcn styled text area" do
    form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

    expected = %(
    <div class="grid gap-2" data-slot="form-item">
      <textarea class="border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 flex field-sizing-content min-h-16 w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 dark:bg-input/30 md:text-sm resize-none"
      name="user[bio]"
      id="user_bio"></textarea>
    </div>)

    assert_dom_equal expected, form.text_area(:bio)
  end

  test "select returns shadcn styled select" do
    form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

    expected = %(<select
      class="border-input data-[placeholder]:text-muted-foreground [&_svg:not([class*='text-'])]:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 flex w-full items-center justify-between gap-2 rounded-md border bg-transparent px-3 py-2 text-sm whitespace-nowrap shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 dark:bg-input/30 dark:hover:bg-input/50 h-9"
      name="user[active]"
      id="user_active"></select>)

    assert_dom_equal expected, form.select(:active, [])
  end

  test "check_box returns shadcn styled check box" do
    form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

    expected = %(<input name="user[active]" type="hidden" value="0" autocomplete="off" />
    <input class="h-4 w-4 rounded border-input bg-background text-primary focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
           type="checkbox" value="1" checked="checked" name="user[active]" id="user_active" />)

    assert_dom_equal expected, form.check_box(:active)
  end

  test "label returns shadcn styled label" do
    form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

    expected = %(<label class="flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50" for="user_name">Name</label>)

    assert_dom_equal expected, form.label(:name, "Name")
  end

  test "submit returns shadcn styled submit button" do
    form = FormBuilders::CustomFormBuilder.new(:user, @form_object, self, {})

    expected = %(<input type="submit" name="commit" value="Create User" class="inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 shrink-0 [&_svg]:shrink-0 outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive bg-primary text-primary-foreground shadow-xs hover:bg-primary/90 h-9 px-4 py-2 has-[>svg]:px-3" data-disable-with="Create User" />)

    assert_dom_equal expected, form.submit("Create User")
  end
  end
end
