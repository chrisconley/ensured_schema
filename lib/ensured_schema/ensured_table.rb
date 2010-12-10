module ActiveRecord
  module ConnectionAdapters
    class EnsuredTable < Table

      def column(column_name, type, options = {})
        if column_exists?(column_name)
          unless column_exists?(column_name, type, options)
            change(column_name, type, options)
          end
        else
          @base.add_column(@table_name, column_name, type, options)
        end
      end

      def remove(column_name)
        super if column_exists?(column_name)
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
          column(name, column_type.to_sym, def_options)
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