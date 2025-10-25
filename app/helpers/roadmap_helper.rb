# frozen_string_literal: true

module RoadmapHelper
  # Returns the appropriate CSS classes for the roadmap grid based on column count
  # Uses explicit Tailwind classes to ensure they're not purged during build
  def roadmap_grid_classes(column_count)
    if column_count <= 3
      # Use grid layout for 1-3 columns with explicit class names
      grid_class = case column_count
      when 1 then "grid-cols-1"
      when 2 then "grid-cols-2"
      when 3 then "grid-cols-3"
      else "grid-cols-1" # Fallback
      end
      "grid #{grid_class} gap-6 pb-4"
    else
      # Use flexbox with horizontal scroll for 4+ columns
      "flex gap-6 overflow-x-auto pb-4"
    end
  end
end
