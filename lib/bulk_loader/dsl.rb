# frozen_string_literal: true

require 'weakref'

module BulkLoader
  module DSL
    module ClassMethods
      def bulk_loader(*args, &block)
        @bulk_loader ||= BulkLoader::ClassAttribute.new
        return @bulk_loader if args.empty?

        name, options = *args
        options ||= {}
        loader = BulkLoader::Loader.new(options, &block)

        @bulk_loader.define_loader(name, loader)

        define_method name do
          bulk_loader.public_send(:test)
        end
      end
    end

    def self.included(mod)
      mod.extend(ClassMethods)
    end

    def bulk_loader
      cattr = self.class.instance_variable_get('@bulk_loader')
      @bulk_loader ||= BulkLoader::Attribute.new(cattr, WeakRef.new(self))
    end
  end
end
