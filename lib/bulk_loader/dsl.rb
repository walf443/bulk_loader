# frozen_string_literal: true

module BulkLoader
  module DSL
    module ClassMethods
      # getter for +BulkLoader::ClassAttribute+
      # If you pass name, mapping, options argument, you can define loader
      # if you does not want to export name to object, pass export: false to options.
      def bulk_loader(*args, export: nil, autoload: true, default: nil, &block)
        @bulk_loader ||= if superclass.respond_to?(:bulk_loader)
                           superclass.bulk_loader.dup
                         else
                           BulkLoader::ClassAttribute.new
                         end

        return @bulk_loader if args.empty?

        name, mapping = *args

        loader = BulkLoader::Loader.new(mapping, default: default, &block)
        @bulk_loader.define_loader(name, loader, autoload: autoload)

        return if export == false

        define_method name do
          bulk_loader.public_send(name)
        end
      end
    end

    def self.included(mod)
      mod.extend(ClassMethods)
    end

    def bulk_loader
      return @bulk_loader if defined?(@bulk_loader) && @bulk_loader

      @bulk_loader = BulkLoader::Attribute.new(self)
    end
  end
end
