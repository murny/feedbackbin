# frozen_string_literal: true

class Account < ApplicationRecord
  include Joinable

  has_one_attached :logo
  has_many :users, dependent: :destroy
end
