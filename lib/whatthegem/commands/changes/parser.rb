module WhatTheGem
  class Changes
    class Parser
      def self.call(filename, content)
        new(filename, content).versions
      end

      class Version < Struct.new(:number, :header, :body, keyword_init: true)
        def initialize(number:, header:, body:)
          super(number: ::Gem::Version.new(number), header: header, body: body)
        end
      end

      VERSION_REGEXP = /^(\d+\.\d+(\.\d+)?)(\s|$)/

      attr_reader :filename, :content

      def initialize(filename, content)
        @filename, @content = Pathname.new(filename), content
      end

      memoize def versions
        case filename.extname
        when /\.(md|markdown)$/i
          markdown_versions
        else
          fail ArgumentError, "Don't know how to parse #{filename}"
        end
      end

      private

      def markdown_versions
        nodes = Kramdown::Document.new(content, input: 'GFM').root.children
        level = nodes
          .select { |n| n.type == :header && n.options[:raw_text].match?(VERSION_REGEXP) }
          .map { |n| n.options[:level] }.min

        sections = nodes
          .chunk { |n| n.type == :header && n.options[:level] == level }
          .drop_while { |header,| !header }
          .map(&:last)
          .each_slice(2)
          .map { |(h, *), nodes| [h.options[:raw_text], nodes] }
          .select { |h,| h.match?(VERSION_REGEXP) }
          .map { |title, nodes|
            Version.new(
              number: title.match(VERSION_REGEXP)[1],
              header: title,
              body: nodes.map(&method(:el2md)).join
            )
          }
          .sort_by(&:number) # it is internall converted to Gem::Version, so "1.12" is correctly > "1.2"
      end

      # Somehow there is no saner methods for converting parsed element back to source /shrug
      def el2md(el)
        el.options[:encoding] = 'UTF-8'
        el.attr.replace({}) # don't render header anchors
        Kramdown::Converter::Kramdown.convert(el, line_width: 1000).first
      end
    end
  end
end