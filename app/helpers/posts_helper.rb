# frozen_string_literal: true

module PostsHelper
  def sort_link(column:, label:)
    direction = (column == session["filters"]["column"]) ? next_direction : "asc"
    link_to(label, posts_path(column: column, direction: direction), data: {turbo_action: "replace"})
  end

  def next_direction
    (session["filters"]["direction"] == "asc") ? "desc" : "asc"
  end

  def sort_indicator
    tag.span(class: "sort sort-#{session["filters"]["direction"]}")
  end

  def show_sort_indicator_for(column)
    sort_indicator if session["filters"]["column"] == column
  end
end
