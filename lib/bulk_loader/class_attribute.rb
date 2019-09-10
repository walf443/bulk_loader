# frozen_string_literal: true

module BulkLoader
  class LoaderNotFoundError < StandardError; end

  class ClassAttribute
    def initialize
      @loader_of = {}
    end

    def include?(name)
      @loader_of.include?(name)
    end

    def each(&block)
      @loader_of.each(&block)
    end

    def load(loader_names, attributes, *args)
      attrs = convert_attributes(attributes)

      loader_names = [loader_names] unless loader_names.is_a?(Array)
      loader_names.each do |name|
        unless @loader_of[name]
          raise LoaderNotFoundError, "bulk_loader :#{name} is not defined"
        end
        @loader_of[name].load(attrs.map { |attr| attr.lazy(name) }, *args)
      end
    end

    def define_loader(name, loader)
      @loader_of[name] = loader
      define_singleton_method(name) { loader }
    end

    def inspect
      "#<BulkLoader::ClassAttribute:#{object_id} #{loader_inspect}>"
    end

    def dup
      new_object = self.class.new
      each do |key, loader|
        new_object.define_loader(key, loader)
      end
      new_object
    end

    private

    def loader_inspect
      @loader_of.map { |name, _| name }.join(' ')
    end

    def convert_attributes(attributes)
      attributes.map(&method(:convert_attribute))
    end

    def convert_attribute(attr)
      if attr.respond_to?(:bulk_loader)
        attr.bulk_loader
      elsif attr.respond_to?(:lazy)
        attr
      else
        raise 'attributes should be BulkLoader::Attribute or BulkLoader::DSL included class!!'
      end
    end
  end
end
