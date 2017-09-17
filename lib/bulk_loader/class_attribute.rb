# frozen_string_literal: true

module BulkLoader
  class ClassAttribute
    def initialize
      @loader_of = {}
    end

    def include?(name)
      @loader_of.include?(name)
    end

    def load(loader_names, attributes, *args)
      attrs = convert_attributes(attributes)

      loader_names = [loader_names] unless loader_names.is_a?(Array)
      loader_names.each do |name|
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

    private

    def loader_inspect
      @loader_of.map { |name, _| name }.join(' ')
    end

    def convert_attributes(attributes)
      attrs = []
      attributes.each do |attr|
        attrs.push(convert_attribute(attr))
      end
      attrs
    end

    def convert_attribute(attr)
      if attr.respond_to?(:lazy)
        attr
      elsif attr.respond_to?(:bulk_loader)
        attr.bulk_loader
      else
        raise 'attributes should be BulkLoader::Attribute or BulkLoader::DSL included class!!'
      end
    end
  end
end
