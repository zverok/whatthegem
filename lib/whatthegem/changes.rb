module WhatTheGem
  class Changes < Command
    register 'changes'

    VERSION_REGEXP = /^(?:v(?:er(?:sion)?)? ?)?(\d+\.\d+(\.\d+(\.\w+)?)?)(\s|:|$)/i

    class Version < Struct.new(:number, :header, :body, keyword_init: true)
      def initialize(number:, header:, body:)
        super(number: ::Gem::Version.new(number), header: header, body: body)
      end

      def to_h
        super.merge(number: number.to_s)
      end
    end

    BundledSince = Struct.new(:version) do
      def to_h
        {description: "your bundled version: #{version}"}
      end
    end

    GlobalSince = Struct.new(:version) do
      def to_h
        {description: "your latest global version: #{version}"}
      end
    end

    SinceFirst = Struct.new(:version) do
      def to_h
        {description: "the first version"}
      end
    end

    TEMPLATE = Template.parse(<<~CHANGES)
      # Changes since {{ since.description }}

      {% for version in versions
      %}## {{ version.header }}

      {{ version.body }}{%
      endfor %}
    CHANGES

    def locals
      {
        since: since.to_h,
        versions: select_versions.reverse.map(&:to_h)
      }
    end

    private

    # TODO: allow to pass `since` as a parameter
    def since
      bundled_since || global_since || SinceFirst.new(versions.first.number)
    end

    def select_versions
      return [] unless versions&.any?
      res = versions.select { |v| v.number > since.version }
      res = versions if res.empty? # if we are at the last version, show all historical changes

      # TODO: If there are a lot of versions, we can do "intellectual selection", like
      # two last minor + last major or something

      res
    end

    def bundled_since
      return unless gem.bundled.present?
      gem.bundled.spec.version.then(&BundledSince.method(:new))
    end

    def global_since
      gem.specs.first&.version&.then(&GlobalSince.method(:new))
    end

    memoize def versions
      best_changelog(versions_from_releases, versions_from_file)
    end

    def versions_from_releases
      gem.github&.releases&.then(&ReleasesParser)
    end

    def versions_from_file
      # always take the freshest from GitHub, even when installed locally
      gem.github&.changelog&.then(&Parser)
    end

    def best_changelog(*changelogs)
      # in case they have both (releases & CHANGELOG.md)...
      list = changelogs.compact.reject(&:empty?)
      return list.first if list.size < 2

      # Some gems have "old" changelog in file, and new in releases, or vice versa
      if list.map { |*, last| last.number }.uniq.one?
        # If both have the same latest version, return one having more text
        list.max_by { |*, last| last.body.size }
      else
        # Return newer, if one of them are
        list.max_by { |*, last| last.number }
      end
    end
  end
end

require_relative 'changes/parser'
require_relative 'changes/releases_parser'
