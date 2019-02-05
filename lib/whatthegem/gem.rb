require 'gems'
require 'octokit'
require 'base64'

module WhatTheGem
  class Gem
    GITHUB_URI_PATTERN = %r{^https?://(www\.)?github\.com/}

    NoGem = Struct.new(:name)

    def self.fetch(name)
      # Empty hash in rubygems info means it does not exist.
      # FIXME: Could be wrong in case of: a) private gems and b) "local-only" command checks
      new(name).then { |gem| gem.rubygems.info.empty?  ? NoGem.new(name) : gem }
    end

    attr_reader :name

    def initialize(name)
      @name = name
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
      repo_url = urls.grep(GITHUB_URI_PATTERN).first or return nil
      Octokit::Repository.from_url(repo_url).slug
    end
  end
end

require_relative 'gem/rubygems'
require_relative 'gem/github'
require_relative 'gem/bundled'