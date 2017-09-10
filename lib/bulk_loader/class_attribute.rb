# frozen_string_literal: true

module BulkLoader
  class ClassAttribute
    def initialize
      @loader_of = {}
    end

    def include?(name)
      @loader_of.include?(name)
    end

    def load(loader_names, attributes)
      loader_names = [loader_names] unless loader_names.is_a?(Array)
      loader_names.each do |name|
        @loader_of[name].load(attributes.map { |attr| attr.lazy(name) })
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
  end
end
