# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  ActionView::Base.default_form_builder = FormBuilders::CustomFormBuilder

  def first_page?(page)
    page == 1
  end

  # Badge component helper for backward compatibility
  def render_badge(text: nil, variant: :default, href: nil, data: {}, **options, &block)
    render Ui::BadgeComponent.new(
      variant: variant,
      href: href,
      text: text,
      data: data,
      **options
    ), &block
  end
end
