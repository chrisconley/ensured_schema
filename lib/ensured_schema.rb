require 'ensured_schema/column'
require 'ensured_schema/mysql_column'
require 'ensured_schema/schema_statements'
require 'ensured_schema/table'
require 'ensured_schema/ensured_table'
require 'ensured_schema/schema'

# module ActiveRecord
#   module ConnectionAdapters
#     class AbstractAdapter
#       def table_exists?(table_name)
#         tables.map(&:downcase).include?(table_name.to_s.downcase)
#       end
#     end
#   end
# end