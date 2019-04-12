require 'liquid'
require 'rouge'

module WhatTheGem
  class Template < Liquid::Template
    module Filters
      def paragraphs(text, num)
        # split on markdown-alike paragraph break (\n\n), or "paragraph, then list" (\n* )
        text.split(/\n(?:\n|(?= *\*))/).first(num).join("\n\n").gsub(/\n +/, "\n").strip
      end

      def reflow(text)
        text.tr("\n", ' ')
      end

      def nfirst(array, num)
        array.first(num)
      end

      # Consistently shift all markdown headers - ### - so they would be at least minlevel deep
      def md_header_shift(text, minlevel)
        current_min = text.scan(/^(\#+) /).flatten.map(&:length).min
        return text if !current_min || current_min > minlevel
        shift = minlevel - current_min
        text.gsub(/^(\#+) /, '#' * shift + '\\1 ')
      end

      def rouge(text)
        lexer = Rouge::Lexers::Ruby.new
        Rouge::Formatters::Terminal256.new(Rouge::Themes::Base16::Monokai.new).format(lexer.lex(text))
      end
    end

    def self.parse(src)
      new.parse(src.chomp.gsub(/\n *({%.+?%})\n/, "\\1\n"))
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