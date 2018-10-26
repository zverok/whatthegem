require 'pastel'

module WhatTheGem
  class Stats
    class Meter < Struct.new(:name, :thresholds, :block)
      def call(gem)
        Metric.new(name, value(gem), *thresholds)
      end

      private

      attr_reader :gem

      def value(gem)
        @gem = gem
        instance_eval(&block)
      rescue NoMethodError # naive way to deal with gem.github.open_issues in blocks, when github is undefined
        nil
      ensure
        @gem = nil
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
          diff = TimeMath.measure(value, Time.now)
          unit, num = diff.detect { |_, v| !v.zero? }
          "#{num} #{unit} ago"
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