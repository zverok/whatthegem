module WhatTheGem
  class Hobject
    class << self
      def deep(hash_or_array)
        deep_value(hash_or_array)
      end

      private

      def deep_value(val)
        case
        when val.respond_to?(:to_hash)
          val.to_hash.transform_values(&method(:deep_value)).then(&method(:new))
        when val.respond_to?(:to_ary)
          val.to_ary.map(&method(:deep_value))
        else
          val
        end
      end
    end

    def initialize(hash)
      @hash = hash.transform_keys(&:to_sym).freeze
      @hash.each do |key, val|
        define_singleton_method(key) { val }
        define_singleton_method("#{key}?") { !!val }
      end
    end

    def to_h
      @hash
    end

    def merge(other)
      Hobject.new(to_h.merge(other.to_h))
    end

    def deep_to_h
      @hash.transform_values(&method(:val_to_h))
    end

    def inspect
      '#<Hobject(%s)>' % @hash.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')
    end

    alias to_s inspect

    private

    def val_to_h(value)
      case value
      when Hobject
        value.deep_to_h
      when Array
        value.map(&method(:val_to_h))
      else
        value
      end
    end
  end
end