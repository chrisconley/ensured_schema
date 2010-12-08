module ActiveRecord
  module ConnectionAdapters
    module SchemaStatements
      # Checks to see if an index exists on a table for a given index definition
      #
      # === Examples
      #  # Check an index exists
      #  index_exists?(:suppliers, :company_id)
      #
      #  # Check an index on multiple columns exists
      #  index_exists?(:suppliers, [:company_id, :company_type])
      #
      #  # Check a unique index exists
      #  index_exists?(:suppliers, :company_id, :unique => true)
      #
      #  # Check an index with a custom name exists
      #  index_exists?(:suppliers, :company_id, :name => "idx_company_id"
      def new_index_exists?(table_name, column_name, options = {}) # Don't overwrite existing index_exists?
        column_names = Array.wrap(column_name)
        index_name = options.key?(:name) ? options[:name].to_s : index_name(table_name, :column => column_names)
        if options[:unique]
          indexes(table_name).any?{ |i| i.unique && i.name == index_name }
        else
          indexes(table_name).any?{ |i| i.name == index_name }
        end
      end

      # Checks to see if a column exists in a given table.
      #
      # === Examples
      #  # Check a column exists
      #  column_exists?(:suppliers, :name)
      #
      #  # Check a column exists of a particular type
      #  column_exists?(:suppliers, :name, :string)
      #
      #  # Check a column exists with a specific definition
      #  column_exists?(:suppliers, :name, :string, :limit => 100)
      def column_exists?(table_name, column_name, type = nil, options = {})
        #debugger
        columns(table_name).any?{ |c| c.name == column_name.to_s &&
                                      (!type                 || c.type.to_s == type.to_s) &&
                                      (!options[:limit]      || c.limit_exists?(options[:limit])) &&
                                      (!options[:precision]  || c.precision == options[:precision]) &&
                                      (!options[:scale]      || c.scale == options[:scale]) }
      end

      def table(table_name, options = {}, &block)
        if table_exists?(table_name)
          puts "table already exists"
          ensure_table(table_name, &block) # what to do about changing table options
        else
          puts "creating table"
          create_table(table_name, options, &block)
        end
      end

      def ensure_table(table_name)
        yield EnsuredTable.new(table_name, self)
      end

      def ensure_index(table_name, column_name, options = {})
        unless new_index_exists?(table_name, column_name, options)
          add_index(table_name, column_name, options)
        end
      end
    end
  end
end