class SharedApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  connects_to database: { writing: :shared }
end
