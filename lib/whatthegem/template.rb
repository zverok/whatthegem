require 'liquid'

module WhatTheGem
  class Template < Liquid::Template
    module Filters
      def paragraphs(text, num)
        text.split("\n\n").first(num).join("\n\n").gsub(/\n +/, "\n").strip
      end

      def nfirst(array, num)
        array.first(num)
      end
    end

    def self.parse(src)
      new.parse(src.rstrip)
    end

    def parse(src)
      super(src, error_mode: :strict)
    end

    def render(data, **options)
      super(Hm.(data).transform_keys(&:to_s).to_h, filters: [Filters], **options)
    end

    alias call render

    def to_proc
      # proc { |data| render(data) }
      method(:call).to_proc
    end
  end
end