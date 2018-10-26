require 'gems'
require 'octokit'
require 'base64'

module WhatTheGem
  class Gem
    class GitHub
      class << self
        memoize def octokit
          if (token = ENV['GITHUB_ACCESS_TOKEN'])
            Octokit::Client.new(access_token: token).tap { |client| client.user.login }
          else
            Octokit::Client.new
          end
        end
      end

      CHANGELOG_PATTERN = /^(history|changelog|changes)(\.\w+)?$/i

      attr_reader :repo_id

      def initialize(repo_id)
        @repo_id = repo_id
      end

      memoize def repository
        req(:repository)
      end

      alias repo repository

      memoize def last_commit
        req(:commits, per_page: 1).first
      end

      memoize def open_issues
        req(:issues, state: 'open', per_page: 50)
      end

      memoize def closed_issues
        req(:issues, state: 'closed', per_page: 50)
      end

      memoize def releases
        req(:releases)
      end

      def contents(path = '.')
        req(:contents, path: path)
      end

      alias files contents

      memoize def changelog
        files.detect { |f| f.name.match?(CHANGELOG_PATTERN) }
          &.then { |f| contents(f.path) }
          &.then(&method(:decode_content))
      end

      private

      def req(method, *args)
        octokit.public_send(method, repo_id, *args).then(&Hobject.method(:deep))
      end

      def decode_content(obj)
        # TODO: encoding is specified as a part of the answer, could it be other than base64?
        obj.merge(text: Base64.decode64(obj.content).force_encoding('UTF-8'))
      end

      def octokit
        self.class.octokit
      end
    end

    class RubyGems
      attr_reader :name

      def initialize(name)
        @name = name
      end

      memoize def info
        req(:info)
      end

      memoize def versions
        req(:versions)
      end

      memoize def reverse_dependencies
        req(:reverse_dependencies)
      end

      private

      def req(method, *args)
        ::Gems.public_send(method, name, *args).then(&Hobject.method(:deep))
      rescue JSON::ParserError => e
        # Gems have no cleaner way to indicate gem does not exist :shrug:
        raise unless e.message.include?('This rubygem could not be found.')
        abort("Gem #{name} does not exist.")
      end
    end

    GITHUB_URI_PATTERN = %r{^https?://(www\.)?github\.com/}

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

    private

    # FIXME: active_record's actual path is https://github.com/rails/rails/tree/v5.2.1/activerecord
    def detect_repo_id(urls)
      repo_url = urls.grep(GITHUB_URI_PATTERN).first or return nil
      Octokit::Repository.from_url(repo_url).slug
    end
  end
end