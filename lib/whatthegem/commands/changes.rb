require_relative '../changelog_parser'

module WhatTheGem
  class Changes < Command
    register 'changes'

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
      gem.github # always take the freshest from GitHub, even when installed locally
        &.changelog
        &.then(&ChangelogParser.method(:call))
    end
  end
end