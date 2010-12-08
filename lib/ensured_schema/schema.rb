module ActiveRecord
  class Schema
    def self.ensure(options={}, &block)
      self.define(options, &block)
    end
  end
end