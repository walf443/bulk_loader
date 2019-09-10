# frozen_string_literal: true

module BulkLoader
  class Loader
    # +mapping+ is a Symbol or Proc. block's 1st argument mapped using mapping.
    # and your block's return value's key should be mapped value.
    def initialize(mapping, default: nil, &block)
      @mapping = mapping
      @is_mapping_proc = @mapping.is_a?(Proc)
      @default = default
      @is_default_proc = @default.is_a?(Proc)
      @block = block
    end

    def load(lazy_objs, *args)
      lazy_obj_of = lazy_objs.each_with_object({}) { |e, h| h[e.target] = e }

      mapping_of = get_mapping(lazy_objs)

      result_of = call_block(mapping_of, *args)

      lazy_objs.each(&:clear)

      set_result_to_lazy_objs(result_of, lazy_obj_of, mapping_of)

      fill_default_to_unloaded_obj(lazy_objs)
    end

    private

    def call_block(mapping_of, *args)
      if args.size < @block.arity - 1
        message = "block should take #{@block.arity} parameters, but given #{arity.size + 1}"
        raise ArgumentError, message
      end
      result_of = @block.call(mapping_of.keys, *args)
      raise 'block shuold return Hash' unless result_of.is_a?(Hash)

      result_of
    end

    def get_mapping(lazy_objs)
      mapping_of = {}
      targets = lazy_objs.map(&:target)
      targets.each do |target|
        mapped_target = @is_mapping_proc ? @mapping.call(target) : target.public_send(@mapping)
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
        lazy_obj.set(@is_default_proc ? @default.call : @default) unless lazy_obj.loaded?
      end
    end
  end
end
