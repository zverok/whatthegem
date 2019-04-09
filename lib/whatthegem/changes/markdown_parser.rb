module WhatTheGem
  class Changes
    class MarkdownParser < Parser
      def versions
        nodes = I::Kramdowns.elements(content)
        level = detect_version_level(nodes) # find level of headers which contain version

        sections = sections(nodes, level)
          .select { |title,| title.match?(VERSION_REGEXP) }
          .map(&method(:make_version))
          .sort_by(&:number) # it is internally converted to Gem::Version, so "1.12" is correctly > "1.2"
      end

      private

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
          body: nodes.map(&I::Kramdowns.method(:el2md)).join
        )
      end
    end
  end
end