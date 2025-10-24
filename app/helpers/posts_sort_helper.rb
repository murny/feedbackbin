# frozen_string_literal: true

module PostsSortHelper
  BASE_SORT_CLASSES = "px-3 py-1.5 rounded-md transition-all duration-200 text-sm font-medium"
  ACTIVE_SORT_CLASSES = "bg-primary text-primary-foreground shadow-sm"
  INACTIVE_SORT_CLASSES = "text-muted-foreground hover:text-foreground hover:bg-muted"

  def posts_sort_active_state(sort_field, direction, params)
    # "created_at" is the default sort, so it's active when no sort is specified
    # or when explicitly set to created_at with desc direction
    if sort_field == "created_at"
      !params.include?(:sort) || params[:sort].blank? || (params[:sort] == sort_field && params[:direction] == direction)
    else
      params.include?(:sort) && params[:sort] == sort_field && params[:direction] == direction
    end
  end

  def posts_sort_link(text:, sort_field:, direction: "desc", params:, path_helper: :posts_path)
    active = posts_sort_active_state(sort_field, direction, params)
    state_classes = active ? ACTIVE_SORT_CLASSES : INACTIVE_SORT_CLASSES
    css_classes = "#{BASE_SORT_CLASSES} #{state_classes}"

    # Build path params - preserve all relevant params (doesn't hurt if they don't exist)
    path_params = {
      sort: sort_field,
      direction: direction,
      category_id: params[:category_id],
      post_status_id: params[:post_status_id],
      search: params[:search]
    }.compact # Remove nil values

    link_to text, send(path_helper, path_params), class: css_classes
  end
end
