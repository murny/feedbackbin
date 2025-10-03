# frozen_string_literal: true

require_relative "feedbackbin_elements/version"
require_relative "feedbackbin_elements/engine"

module FeedbackbinElements
  mattr_accessor :importmap, default: Importmap::Map.new
end
