require 'pastel'

module WhatTheGem
  class Stats
    class Meter < Struct.new(:name, :path, :thresholds, :block)
      def call(gem)
        dig(gem, *path)
          &.then(&block)
          &.then { |val| Metric.new(name, val, *thresholds) }
      end

      private

      def dig(value, first = nil, *rest)
        return value unless first
        case value
        when ->(v) { first.is_a?(Symbol) && v.respond_to?(first) }
          dig(value.public_send(first), *rest)
        when Hash, Array
          value.dig(first, *rest)
        else
          fail "Can't dig #{first} in #{value}"
        end
      end
    end

    class Metric
      attr_reader :value, :name, :color

      def initialize(name, value, *thresholds)
        @name = name
        @value = value
        @color = deduce_color(*thresholds)
      end

      def format
        '%20s: %s' % [name, colorized_value]
      end

      private

      def colorized_value
        Pastel.new.send(color, formatted_value)
      end

      def formatted_value
        case value
        when nil
          '—'
        when String
          value
        when Numeric
          # 100000 => 100,000
          value.to_s.chars.reverse.each_slice(3).to_a.map(&:join).join(',').reverse
        when Date, Time
          I.ago_text(value)
        else
          fail ArgumentError, "Unformattable #{value.inspect}"
        end
      end

      def deduce_color(red = nil, yellow = nil)
        return :dark if value.nil?
        return :white if !yellow # no thresholds given

        # special trick to tell "lower is better" from "higher is better" situations
        val = red.is_a?(Numeric) && red < 0 ? -value : value

        case
        when val < red then :red
        when val < yellow then :yellow
        else :green
        end
      end
    end
  end
end