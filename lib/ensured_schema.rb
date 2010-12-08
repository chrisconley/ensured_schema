module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      def table_exists?(table_name)
        tables.map(&:downcase).include?(table_name.to_s.downcase)
      end
    end

    module SchemaStatements
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
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    class Column
      def limit_exists?(new_limit)
        self.limit == new_limit
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    class MysqlColumn
      def limit_exists?(new_limit)
        return super unless type.to_s == 'integer'
        case new_limit
        when 5..8
          self.limit == 8
        when nil, 4, 11
          self.limit == 4
        else
          self.limit == new_limit
        end
      end
    end
  end
end


module ActiveRecord
  module ConnectionAdapters
    class EnsuredTable < Table

      def column_exists?(column_name, type = nil, options = {})
        #debugger
        @base.column_exists?(@table_name, column_name, type, options)
      end

      %w( string text integer float decimal datetime timestamp time date binary boolean ).each do |column_type|
        class_eval <<-EOV
          def #{column_type}(*args)                   # def string(*args)
            define_columns('#{column_type}', *args)    #   define_column('string', *args)
          end                                         # end
        EOV
      end

      def define_columns(column_type, *args)
        options = args.extract_options!
        column_names = args

        column_names.each do |name|
          column_def = build_column_definition(name, column_type, options)
          def_options = column_def.members.inject({}){|h, k| h[k.to_sym] = column_def[k]; h;}
          #debugger
          if column_exists?(name)
            unless column_exists?(name, column_type, def_options)
              debugger
              change(name, column_def.sql_type, options)
              puts "#{name} has been changed!"
            end
          else
            puts "creating column"
            @base.add_column(@table_name, name, column_def.sql_type, options)
          end
        end
      end

      def build_column_definition(column_name, column_type, options = {})
        column = ColumnDefinition.new(@base, column_name, column_type)
        if options[:limit]
          column.limit = options[:limit]
        elsif native[column_type.to_sym].is_a?(Hash)
          column.limit = native[column_type.to_sym][:limit]
        end
        column.precision = options[:precision]
        column.scale = options[:scale]
        column.default = options[:default]
        column.null = options[:null]
        column
      end
    end
  end
end

module ActiveRecord
  class Schema
    def self.ensure(options={}, &block)
      self.define(options, &block)
    end
  end
end

module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module SchemaStatements
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
        begin
          add_index(table_name, column_name, options)
        rescue => e
          if e.message =~ /Duplicate key/
            puts "index already exists"
          else
            raise e
          end
        end
      end
    end
  end
end