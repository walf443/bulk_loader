# frozen_string_literal: true

module BulkLoader
  class Attribute
    def initialize(cattr, target)
      @cattr = cattr
      @target = target
      @lazy_of ||= {}
    end

    def lazy(name)
      @lazy_of[name] ||= BulkLoader::Lazy.new(@target)
    end

    private

    def method_missing(name, *args)
      return super unless @cattr.include?(name)
      define_singleton_method(name) do
        lazy(name).get
      end
      public_send(name)
    end

    def respond_to_missing?(name, include_private)
      return true if @cattr.include?(name)
      super
    end
  end
end
