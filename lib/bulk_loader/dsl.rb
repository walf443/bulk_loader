# frozen_string_literal: true

require 'weakref'

module BulkLoader
  module DSL
    module ClassMethods
      # getter for +BulkLoader::ClassAttribute+
      # If you pass name, mapping, options argument, you can define loader
      # if you does not want to export name to object, pass export: false to options.
      def bulk_loader(*args, &block)
        unless @bulk_loader
          if superclass.respond_to?(:bulk_loader)
            @bulk_loader = superclass.bulk_loader.dup
          else
            @bulk_loader = BulkLoader::ClassAttribute.new
          end
        end
        return @bulk_loader if args.empty?

        name, mapping, options = *args
        options ||= {}
        does_export = options.delete(:export)

        @bulk_loader.define_loader(name, BulkLoader::Loader.new(mapping, options, &block))

        return if does_export == false

        define_method name do
          bulk_loader.public_send(name)
        end
      end
    end

    def self.included(mod)
      mod.extend(ClassMethods)
    end

    def bulk_loader
      return @bulk_loader if @bulk_loader

      class_attribute = self.class.bulk_loader
      @bulk_loader = BulkLoader::Attribute.new(class_attribute, WeakRef.new(self))
    end
  end
end
