# frozen_string_literal: true

module Ui
  class BaseComponent < ViewComponent::Base
    # Shared utility for merging Tailwind classes
    def tw_merge(*classes)
      TailwindMerge::Merger.new.merge(classes.compact.join(" "))
    end
  end
end
