require 'bundler'

module WhatTheGem
  class Gem
    class Bundled
      NoBundle = Struct.new(:name) do
        def to_h
          {type: 'nobundle'}
        end
      end

      NotBundled = Struct.new(:name) do
        def to_h
          {type: 'notbundled', name: name}
        end
      end

      def self.fetch(name)
        return NoBundle.new(name) unless File.exists?('Gemfile') && File.exists?('Gemfile.lock')

        definition = Bundler::Definition.build('Gemfile', 'Gemfile.lock', nil)
        spec = definition.locked_gems.specs.detect { |s| s.name == name } or return NotBundled.new(name)
        spec.send(:__materialize__)
        new(spec)
      end

      attr_reader :spec

      def initialize(spec)
        @spec = spec
      end

      def to_h
        {
          type: 'bundled',
          name: spec.name,
          version: spec.version.to_s,
          dir: spec.gem_dir
        }
      end
    end
  end
end