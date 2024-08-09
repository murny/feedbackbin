# frozen_string_literal: true

class Post < ApplicationRecord
  include ModelSortable

  broadcasts_refreshes

  validates :title, presence: true
end
