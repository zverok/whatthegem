module WhatTheGem
  class ChangelogParser
    def self.call(file)
      new(file).versions
    end

    class Version < Struct.new(:number, :header, :body, keyword_init: true)
      def initialize(number:, header:, body:)
        super(number: ::Gem::Version.new(number), header: header, body: body)
      end

      def to_h
        super.merge(number: number.to_s)
      end
    end

    VERSION_REGEXP = /^(?:v(?:er(?:sion)?)? ?)?(\d+\.\d+(\.\d+)?)(\s|$)/i

    attr_reader :file

    def initialize(file)
      @file = file
    end

    memoize def versions
      case file.basename
      when /\.(md|markdown)$/i
        markdown_versions
      else
        fail ArgumentError, "Don't know how to parse #{filename}"
      end
    end

    private

    memoize def content
      file.read
    end

    def markdown_versions
      nodes = Kramdown::Document.new(content, input: 'GFM').root.children
      level = detect_version_level(nodes) # find level of headers which contain version

      sections = sections(nodes, level)
        .select { |title,| title.match?(VERSION_REGEXP) }
        .map(&method(:make_version))
        .sort_by(&:number) # it is internally converted to Gem::Version, so "1.12" is correctly > "1.2"
    end

    def sections(nodes, level)
      nodes
        .chunk { |n| n.type == :header && n.options[:level] == level } # chunk into sections by header
        .drop_while { |header,| !header }                              # drop before first header
        .map(&:last)                                                   # drop `true`, `false` flags after chunk
        .each_slice(2)                                                 # join header with subsequent nodes
        .map { |(h, *), nodes| [h.options[:raw_text], nodes] }
    end

    def detect_version_level(nodes)
      nodes
        .select { |n| n.type == :header && n.options[:raw_text].match?(VERSION_REGEXP) }
        .map { |n| n.options[:level] }.min
    end

    def make_version((title, nodes))
      # TODO: date, if known
      Version.new(
        number: title[VERSION_REGEXP, 1],
        header: title,
        body: nodes.map(&method(:el2md)).join
      )
    end

    # Somehow there is no saner methods for converting parsed element back to source :shrug:
    def el2md(el)
      el.options[:encoding] = 'UTF-8'
      el.attr.replace({}) # don't render header anchors
      Kramdown::Converter::Kramdown.convert(el, line_width: 1000).first
    end
  end
end