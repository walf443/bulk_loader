# frozen_string_literal: true

module BulkLoader
  class UnloadAccessError < StandardError; end

  # lazy class
  class Lazy
    attr_reader :target

    def initialize(target, name: nil)
      @loaded = false
      @value = nil
      @name = name
      @target = target
    end

    def get
      raise UnloadAccessError, "#{@name} has not been loaded!!" unless @loaded

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
