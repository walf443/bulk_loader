# frozen_string_literal: true

module BulkLoader
  class Loader
    def initialize(mapping, default: nil, binds: [], &block)
      @mapping = mapping
      @default = default
      @binds = binds
      @block = block
    end

    def load(lazy_objs)
      lazy_obj_of = lazy_objs.each_with_object({}) { |e, h| h[e.target] = e }

      mapping_of = get_mapping(lazy_objs)

      result_of = @block.call(mapping_of.keys, *@binds)
      raise 'block shuold return Hash' unless result_of.is_a?(Hash)

      lazy_objs.each(&:clear)

      set_result_to_lazy_objs(result_of, lazy_obj_of, mapping_of)

      fill_default_to_unloaded_obj(lazy_objs)
    end

    private

    def get_mapping(lazy_objs)
      mapping_of = {}
      targets = lazy_objs.map(&:target)
      targets.each do |target|
        mapped_target = target.public_send(@mapping)
        mapping_of[mapped_target] = [] unless mapping_of[mapped_target]
        mapping_of[mapped_target].push(target)
      end
      mapping_of
    end

    def set_result_to_lazy_objs(result_of, lazy_obj_of, mapping_of)
      result_of.each do |mapped_target, value|
        next unless mapping_of[mapped_target]
        mapping_of[mapped_target].each do |target|
          lazy_obj_of[target]&.set(value)
        end
      end
    end

    def fill_default_to_unloaded_obj(lazy_objs)
      lazy_objs.each do |lazy_obj|
        lazy_obj.set(@default) unless lazy_obj.loaded?
      end
    end
  end
end
