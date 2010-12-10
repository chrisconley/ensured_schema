module ActiveRecord
  module ConnectionAdapters
    class EnsuredTable < Table

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