require "cases/helper"


if ActiveRecord::Base.connection.supports_migrations?
  class EnsuredSchemaTest < ActiveRecord::TestCase
    def setup
      @conn = ActiveRecord::Base.connection
      @conn.drop_table("test_table") if @conn.table_exists?("test_table")
    end

    def test_table
      assert_nothing_raised do
        ActiveRecord::Schema.ensure(:version => '1') do
          table("test_table", :id => false, :force => true) do |t|
            t.string "TABLE_NAME",  :limit => 30, :default => "", :null => false
          end
          table("test_table", :id => false, :force => true) do |t|
            t.string "TABLE_NAME",  :limit => 30, :default => "", :null => false
          end
        end
      end
    end
  end
end