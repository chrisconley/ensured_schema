module ActiveRecord
  module ConnectionAdapters
    class Column
      def limit_exists?(new_limit)
        self.limit == new_limit
      end
    end
  end
end