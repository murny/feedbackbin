# frozen_string_literal: true

module Ideas
  class StatusBadgeComponent < Elements::BaseComponent
    def initialize(idea:)
      @idea = idea
    end
  end
end
