# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  tenanted
  
  connects_to database: { writing: :primary }
end
