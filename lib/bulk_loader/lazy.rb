# frozen_string_literal: true

module BulkLoader
  # lazy class
  class Lazy
    attr_reader :target

    def initialize(target)
      @loaded = false
      @value = nil
      @target = target
    end

    def get
      raise 'data is not loaded!!' unless @loaded
      @value
    end

    def set(value)
      @loaded = true
      @value = value
    end

    def clear
      @loaded = false
      @value = nil
    end

    def loaded?
      @loaded
    end
  end
end
