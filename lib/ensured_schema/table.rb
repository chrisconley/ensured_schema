module ActiveRecord
  module ConnectionAdapters
    class Table

      def column_exists?(column_name, type = nil, options = {})
        @base.column_exists?(@table_name, column_name, type, options)
      end
    end
  end
end