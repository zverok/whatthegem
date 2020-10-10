require 'rdoc'
require 'kramdown'
require 'pastel'

require 'kramdown-parser-gfm'

module WhatTheGem
  # I for Internal
  # @private
  module I
    extend self

    module Callable
      def to_proc
        proc { |*args| call(*args) }
      end
    end

    Pastel = ::Pastel.new

    module Kramdowns
      extend self

      def elements(source)
        Kramdown::Document.new(source, input: 'GFM').root.children
      end

      # Somehow there is no saner methods for converting parsed element back to source :shrug:
      def el2md(el)
        el.options[:encoding] = 'UTF-8'
        el.attr.replace({}) # don't render header anchors
        Kramdown::Converter::Kramdown.convert(el, line_width: 1000).first
      end
    end

    module RDocs
      extend self

      def parts(source)
        RDoc::Comment.new(source).parse.parts
      end

      def part2md(part)
        formatter = RDoc::Markup::ToMarkdown.new
        RDoc::Markup::Document.new(part).accept(formatter)
      end
    end

    def ago_text(tm)
      diff = TimeCalc.now.-(tm).factorize
      unit, num = diff.detect { |_, v| !v.zero? }
      "#{num} #{unit} ago"
    end
  end
end
