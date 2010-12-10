require "cases/helper"

require 'models/person'

if ActiveRecord::Base.connection.supports_migrations?
  class ActiveRecord::Migration
    class <<self
      attr_accessor :message_count
      def puts(text="")
        self.message_count ||= 0
        self.message_count += 1
      end
    end
  end

  class EnsuredSchemaTest < ActiveRecord::TestCase
    def setup
      @conn = ActiveRecord::Base.connection
      @conn.drop_table("testings") if @conn.table_exists?("testings")
      @conn.drop_table("testings") if @conn.table_exists?("testings")
    end

    def test_table_definition
      assert_nothing_raised do
        ActiveRecord::Schema.ensure(:version => '1') do
          table(:testings, :id => false, :force => true) do |t|
            t.string :test,  :limit => 30, :default => "", :null => false
          end
        end

        ActiveRecord::Schema.ensure(:version => '1') do
          table(:testings, :id => false, :force => true) do |t|
            t.string :test,  :limit => 30, :default => "", :null => false
          end
        end
      end
      assert @conn.table_exists?("testings")
    end

    def test_column_definition_does_not_raise
      assert_nothing_raised do
        ActiveRecord::Schema.ensure(:version => '1') do
          table(:testings, :id => false, :force => true) do |t|
            t.string :test,  :limit => 30, :default => "", :null => false
            t.column :test2, :string
          end
          table(:testings, :id => false, :force => true) do |t|
            t.expects(:change).never
            t.string :test,  :limit => 30, :default => "", :null => false
            t.column :test2, :string
          end
        end
      end
    end

    # From original column_exists? patch in Rails 3: https://rails.lighthouseapp.com/projects/8994/tickets/4219
    def test_column_exists
      Person.connection.create_table :testings do |t|
        t.column :foo, :string
      end

      assert Person.connection.column_exists?(:testings, :foo)
      assert !Person.connection.column_exists?(:testings, :bar)
    ensure
      Person.connection.drop_table :testings rescue nil
    end

    # From original column_exists? patch in Rails 3: https://rails.lighthouseapp.com/projects/8994/tickets/4219
    def test_column_exists_with_type
      Person.connection.create_table :testings do |t|
        t.column :foo, :string
        t.column :bar, :decimal, :precision => 8, :scale => 2
      end

      assert Person.connection.column_exists?(:testings, :foo, :string)
      assert !Person.connection.column_exists?(:testings, :foo, :integer)
      assert Person.connection.column_exists?(:testings, :bar, :decimal)
      assert !Person.connection.column_exists?(:testings, :bar, :integer)
    ensure
      Person.connection.drop_table :testings rescue nil
    end

    # From original column_exists? patch in Rails 3: https://rails.lighthouseapp.com/projects/8994/tickets/4219
    def test_column_exists_with_definition
      Person.connection.create_table :testings do |t|
        t.column :foo, :string, :limit => 100
        t.column :bar, :decimal, :precision => 8, :scale => 2
      end

      assert Person.connection.column_exists?(:testings, :foo, :string, :limit => 100)
      assert !Person.connection.column_exists?(:testings, :foo, :string, :limit => 50)
      assert Person.connection.column_exists?(:testings, :bar, :decimal, :precision => 8, :scale => 2)
      assert !Person.connection.column_exists?(:testings, :bar, :decimal, :precision => 10, :scale => 2)
    ensure
      Person.connection.drop_table :testings rescue nil
    end

    # From original column_exists? patch in Rails 3: https://rails.lighthouseapp.com/projects/8994/tickets/4219
    def test_new_index_exists?
      Person.connection.create_table :testings do |t|
        t.column :foo, :string, :limit => 100
        t.column :bar, :string, :limit => 100
      end
      Person.connection.add_index :testings, :foo

      assert Person.connection.new_index_exists?(:testings, :foo)
      assert !Person.connection.new_index_exists?(:testings, :bar)
    ensure
      Person.connection.drop_table :testings rescue nil
    end

    # From original column_exists? patch in Rails 3: https://rails.lighthouseapp.com/projects/8994/tickets/4219
    def test_new_index_exists?_on_multiple_columns
      Person.connection.create_table :testings do |t|
        t.column :foo, :string, :limit => 100
        t.column :bar, :string, :limit => 100
      end
      Person.connection.add_index :testings, [:foo, :bar]

      assert Person.connection.new_index_exists?(:testings, [:foo, :bar])
    ensure
      Person.connection.drop_table :testings rescue nil
    end

    # From original column_exists? patch in Rails 3: https://rails.lighthouseapp.com/projects/8994/tickets/4219
    def test_unique_new_index_exists?
      Person.connection.create_table :testings do |t|
        t.column :foo, :string, :limit => 100
      end
      Person.connection.add_index :testings, :foo, :unique => true

      assert Person.connection.new_index_exists?(:testings, :foo, :unique => true)
    ensure
      Person.connection.drop_table :testings rescue nil
    end

    # From original column_exists? patch in Rails 3: https://rails.lighthouseapp.com/projects/8994/tickets/4219
    def test_named_new_index_exists?
      Person.connection.create_table :testings do |t|
        t.column :foo, :string, :limit => 100
      end
      Person.connection.add_index :testings, :foo, :name => "custom_index_name"

      assert Person.connection.new_index_exists?(:testings, :foo, :name => "custom_index_name")
    ensure
      Person.connection.drop_table :testings rescue nil
    end

    def test_column_exists_with_integer_limit
      @conn.create_table :testings do |t|
        t.column :one,    :integer, :limit => 1
        t.column :two,    :integer, :limit => 2
        t.column :three,  :integer, :limit => 3
        t.column :four,   :integer, :limit => 4
        t.column :five,   :integer, :limit => 5
        t.column :six,    :integer, :limit => 6
        t.column :seven,  :integer, :limit => 7
        t.column :eight,  :integer, :limit => 8
        t.column :eleven, :integer, :limit => 11
      end

      assert @conn.column_exists?(:testings, :one,    :integer, :limit => 1)
      assert @conn.column_exists?(:testings, :two,    :integer, :limit => 2)
      assert @conn.column_exists?(:testings, :three,  :integer, :limit => 3)
      assert @conn.column_exists?(:testings, :four,   :integer, :limit => 4)
      assert @conn.column_exists?(:testings, :five,   :integer, :limit => 5)
      assert @conn.column_exists?(:testings, :six,    :integer, :limit => 6)
      assert @conn.column_exists?(:testings, :seven,  :integer, :limit => 7)
      assert @conn.column_exists?(:testings, :eight,  :integer, :limit => 8)
      assert @conn.column_exists?(:testings, :eleven, :integer, :limit => 11)
    end

    def test_column_gets_changed
      ActiveRecord::Schema.ensure(:version => '1') do
        table(:testings, :id => false, :force => true) do |t|
          t.string :test,  :limit => 30, :default => "", :null => false
        end
        table(:testings, :id => false, :force => true) do |t|
          t.string :test,  :limit => 20, :default => "", :null => false
        end
      end

      assert !@conn.column_exists?(:testings, :test, :string, :limit => 30)
      assert @conn.column_exists?(:testings, :test, :string, :limit => 20, :default => "", :null => false)
      assert @conn.column_exists?(:testings, :test)
    end

    def test_column_is_removed_once
      assert_nothing_raised do
        ActiveRecord::Schema.ensure(:version => '1') do
          table(:testings, :id => false, :force => true) do |t|
            t.string :test,  :limit => 30, :default => "", :null => false
            t.string :test2
            t.remove(:test)
            t.remove(:test)
          end
        end

        ActiveRecord::Schema.ensure(:version => '1') do
          table(:testings, :id => false, :force => true) do |t|
            t.remove(:test)
          end
        end
      end
      assert !@conn.column_exists?(:testings, :test)
    end

    def test_ensure_index
      assert_nothing_raised do
        ActiveRecord::Schema.ensure(:version => '1') do
          table(:testings, :id => false, :force => true) do |t|
            t.string :test,  :limit => 30, :default => "", :null => false
          end
          ensure_index :testings, [:test], :name => "test_index", :unique => true
          ensure_index :testings, [:test], :name => "test_index", :unique => true
        end
      end
      assert @conn.new_index_exists?(:testings, :test, :name => "test_index")
    end

    protected
    def with_change_table
      Person.connection.change_table :delete_me do |t|
        yield t
      end
    end
  end
end