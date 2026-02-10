# frozen_string_literal: true

module IdeasSortHelper
  BASE_SORT_CLASSES = "border-radius txt-small font-weight-medium"
  BASE_SORT_STYLE = "padding: 0.375rem 0.75rem;"
  ACTIVE_SORT_CLASSES = "fill-primary txt-reversed shadow-sm"
  INACTIVE_SORT_CLASSES = "txt-subtle"

  # Helper method to clean params by removing nil and blank values
  def clean_params(**params)
    params.compact.reject { |_k, v| v.blank? }
  end

  def ideas_sort_active_state(sort_field, direction, params)
    # "created_at" is the default sort, so it's active when no sort is specified
    # or when explicitly set to created_at with desc direction
    if sort_field == "created_at"
      !params.include?(:sort) || params[:sort].blank? || (params[:sort] == sort_field && params[:direction] == direction)
    else
      params.include?(:sort) && params[:sort] == sort_field && params[:direction] == direction
    end
  end

  def ideas_sort_link(text:, sort_field:, direction: "desc", params:, path_helper: :ideas_path, turbo_frame: nil)
    active = ideas_sort_active_state(sort_field, direction, params)
    state_classes = active ? ACTIVE_SORT_CLASSES : INACTIVE_SORT_CLASSES
    css_classes = "#{BASE_SORT_CLASSES} #{state_classes}"

    # Build path params - preserve all relevant params (doesn't hurt if they don't exist)
    path_params = {
      sort: sort_field,
      direction: direction,
      board_id: params[:board_id],
      status_id: params[:status_id],
      search: params[:search]
    }.compact # Remove nil values

    # Build link options
    link_options = { class: css_classes, style: BASE_SORT_STYLE }
    link_options[:data] = { turbo_frame: turbo_frame } if turbo_frame

    link_to text, send(path_helper, path_params), **link_options
  end
end
