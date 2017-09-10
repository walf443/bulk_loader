# frozen_string_literal: true

module BulkLoader
  class Loader
    def initialize(default: nil, binds: [], &block)
      @default = default
      @binds = binds
      @block = block
    end

    def load(lazy_objs)
      lazy_obj_of = lazy_objs.each_with_object({}) { |e, h| h[e.target] = e }
      targets = lazy_objs.map(&:target)

      result_of = @block.call(targets, *@binds)
      raise 'block shuold return Hash' unless result_of.is_a?(Hash)

      lazy_objs.each(&:clear)

      result_of.each do |target, value|
        lazy_obj_of[target]&.set(value)
      end

      fill_default_to_unloaded_obj(lazy_objs)
    end

    private

    def fill_default_to_unloaded_obj(lazy_objs)
      lazy_objs.each do |lazy_obj|
        lazy_obj.set(@default) unless lazy_obj.loaded?
      end
    end
  end
end
