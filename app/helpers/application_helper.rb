# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  ActionView::Base.default_form_builder = FormBuilders::CustomFormBuilder

  def first_page?(page)
    page == 1
  end
end
