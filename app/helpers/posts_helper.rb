# frozen_string_literal: true

module PostsHelper
  def sort_link(column:, label:)
    direction = (column == params[:column]) ? next_direction : "asc"
    link_to(posts_path(column: column, direction: direction, status_id: params[:status_id], title: params[:title]), data: {turbo_action: "replace"}, class: "flex items-center") do
      tag.span(label) + show_sort_indicator_for(column)
    end
  end

  def next_direction
    (params[:direction] == "asc") ? "desc" : "asc"
  end

  def sort_indicator
    if params[:direction] == "asc"
      image_tag("arrow-up.svg", class: "w-3 h-3 ms-1.5 filter invert")
    else
      image_tag("arrow-down.svg", class: "w-3 h-3 ms-1.5 filter invert")
    end
  end

  def show_sort_indicator_for(column)
    if params[:column] == column
      sort_indicator if params[:column] == column
    else
      image_tag("arrows-up-down.svg", class: "w-3 h-3 ms-1.5 filter invert")
    end
  end
end
