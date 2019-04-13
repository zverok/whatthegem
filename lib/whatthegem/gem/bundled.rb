require 'bundler'

module WhatTheGem
  class Gem
    class Bundled
      NoBundle = Struct.new(:name) do
        def to_h
          {type: 'nobundle'}
        end

        def present?
          false
        end
      end

      NotBundled = Struct.new(:name) do
        def to_h
          {type: 'notbundled', name: name}
        end

        def present?
          false
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

      def present?
        true
      end

      def materialized?
        !spec.instance_variable_get('@specification').nil?
      end

      def to_h
        {
          type: 'bundled',
          name: spec.name,
          version: spec.version.to_s,
          dir: materialized? ? spec.gem_dir : '(not installed)'
        }
      end
    end
  end
end