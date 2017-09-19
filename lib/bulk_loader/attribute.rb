# frozen_string_literal: true

module BulkLoader
  class Attribute
    def initialize(cattr, target)
      @class_attribute = cattr
      @target = target
      @lazy_of ||= {}
    end

    def lazy(name)
      @lazy_of[name] ||= BulkLoader::Lazy.new(@target)
    end

    private

    def method_missing(name, *args)
      return super unless @class_attribute.include?(name)
      names = [name].freeze
      define_singleton_method(name) do
        attr = lazy(name)
        @class_attribute.load(names, [self]) unless attr.loaded?
        attr.get
      end
      public_send(name)
    end

    def respond_to_missing?(name, include_private)
      return true if @class_attribute.include?(name)
      super
    end
  end
end
