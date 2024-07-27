# frozen_string_literal: true

class Account < ApplicationRecord
  include Joinable

  has_one_attached :logo
end
