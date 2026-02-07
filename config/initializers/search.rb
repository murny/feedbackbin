# frozen_string_literal: true

# Exclude the FTS5 virtual table from schema.rb since it cannot be represented
# in Ruby schema format. The table is created via migration using raw SQL.
#
# Rails' SQLite schema dumper doesn't check ignore_tables for virtual tables,
# so we patch it to filter them out.
Rails.application.config.after_initialize do
  ActiveRecord::ConnectionAdapters::SQLite3::SchemaDumper.prepend(Module.new do
    private

      def virtual_tables(stream)
        @connection.define_singleton_method(:virtual_tables) do
          super().reject { |table_name, _| table_name == "search_records_fts" }
        end
        super
      end
  end)
end
