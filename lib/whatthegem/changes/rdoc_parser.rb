module WhatTheGem
  class Changes
    # FIXME: It kinda duplicates MarkdownParser for the _logic_, so should be unified somehow?
    class RDocParser < Parser
      def versions
        nodes = I::RDocs.parts(content)
        level = detect_version_level(nodes) # find level of headers which contain version

        sections = sections(nodes, level)
          .select { |title,| title.match?(VERSION_REGEXP) }
          .map(&method(:make_version))
          .sort_by(&:number) # it is internally converted to Gem::Version, so "1.12" is correctly > "1.2"
      end

      private

      def sections(nodes, level)
        nodes
          .chunk { |n| n.is_a?(RDoc::Markup::Heading) && n.level == level } # chunk into sections by header
          .drop_while { |header,| !header }                                 # drop before first header
          .map(&:last)                                                      # drop `true`, `false` flags after chunk
          .each_slice(2)                                                    # join header with subsequent nodes
          .map { |(h, *), nodes| [h.text, nodes] }
      end

      def detect_version_level(nodes)
        nodes.grep(RDoc::Markup::Heading)
          .select { |n| n.text.match?(VERSION_REGEXP) }
          .map(&:level).min
      end

      def make_version((title, nodes))
        # TODO: date, if known
        Version.new(
          number: title[VERSION_REGEXP, 1],
          header: title,
          body: nodes.map(&I::RDocs.method(:part2md)).join
        )
      end
    end
  end
end