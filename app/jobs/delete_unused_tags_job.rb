# frozen_string_literal: true

class DeleteUnusedTagsJob < ApplicationJob
  def perform
    Tag.unused.find_each(&:destroy!)
  end
end
