# frozen_string_literal: true

# Handles associations that cross tenant boundaries (e.g., tenant models referencing shared users)
module CrossTenantAssociations
  extend ActiveSupport::Concern

  class_methods do
    # Define a cross-tenant belongs_to association to a shared model
    def belongs_to_shared(name, **options)
      foreign_key = options[:foreign_key] || "#{name}_id"
      class_name = options[:class_name] || name.to_s.classify

      # Define the association method
      define_method(name) do
        instance_variable_get("@#{name}") || begin
          if (id = public_send(foreign_key))
            shared_record = class_name.constantize.find_by(id: id)
            instance_variable_set("@#{name}", shared_record)
          end
        end
      end

      # Define the setter method
      define_method("#{name}=") do |record|
        instance_variable_set("@#{name}", record)
        public_send("#{foreign_key}=", record&.id)
      end

      # Define validation if required
      if options[:required] != false
        validates foreign_key, presence: true
      end
    end
  end
end