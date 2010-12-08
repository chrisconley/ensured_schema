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