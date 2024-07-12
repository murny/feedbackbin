class Account < ApplicationRecord
  include Joinable

  has_one_attached :logo
end
