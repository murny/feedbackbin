# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  # TODO: Refactor existing forms to use the TailwindFormBuilder first
  # ActionView::Base.default_form_builder = FormBuilders::TailwindFormBuilder

  def first_page?(page)
    page == 1
  end
end
