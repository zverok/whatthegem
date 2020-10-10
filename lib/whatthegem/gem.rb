require 'gems'
require 'octokit'
require 'base64'

module WhatTheGem
  class Gem
    GITHUB_URI_PATTERN = %r{^https?://(www\.)?github\.com/}

    NoGem = Struct.new(:name) do
      def exists?
        false
      end
    end

    def self.fetch(name)
      new(name).tap { |gem| gem.rubygems.info } # This will fail with Gems::NotFound if it is nonexisting
    rescue Gems::NotFound
      NoGem.new(name)
    end

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def exists?
      true
    end

    memoize def rubygems
      RubyGems.new(name)
    end

    memoize def github
      rubygems.info.to_h.values_at(:source_code_uri, :homepage_uri)
        .then(&method(:detect_repo_id))
        &.then(&GitHub.method(:new))
    end

    memoize def specs
      ::Gem::Specification.select { |s| s.name == name }.sort_by(&:version)
    end

    memoize def bundled
      Bundled.fetch(name)
    end

    private

    # FIXME: active_record's actual path is https://github.com/rails/rails/tree/v5.2.1/activerecord
    def detect_repo_id(urls)
      # Octokit can't correctly guess repo slug from https://github.com/bitaxis/annotate_models.git
      urls.grep(GITHUB_URI_PATTERN).first
          &.sub(/\.git$/, '')
          &.then(&Octokit::Repository.method(:from_url))
          &.slug
    end
  end
end

require_relative 'gem/rubygems'
require_relative 'gem/github'
require_relative 'gem/bundled'
