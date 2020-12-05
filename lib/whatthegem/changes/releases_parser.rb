module WhatTheGem
  class Changes
    class ReleasesParser
      extend I::Callable

      def self.call(releases)
        new(releases).versions
      end

      attr_reader :releases

      def initialize(releases)
        @releases = releases
      end

      def versions
        releases.map { |rel|
          tag_name, name, body = rel.fetch_values(:tag_name, :name, :body)
          Version.new(
            number: tag_name[VERSION_LINE_REGEXP, :version],
            header: name.then.reject(&:empty?).first || tag_name,
            body: body
          )
        }.sort_by(&:number)
      end
    end
  end
end
