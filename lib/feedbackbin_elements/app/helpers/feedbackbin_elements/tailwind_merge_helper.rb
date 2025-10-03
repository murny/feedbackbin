# frozen_string_literal: true

require "tailwind_merge"

module FeedbackbinElements
  module TailwindMergeHelper
    def tw_merge(*classes)
      TailwindMerge::Merger.new.merge(classes.join(" "))
    end
  end
end
