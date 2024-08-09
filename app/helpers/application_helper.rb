# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def first_page?(page)
    page == 1
  end
end
