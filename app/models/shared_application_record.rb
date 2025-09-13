class SharedApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :shared }
end
