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
        locate_file(CHANGELOG_PATTERN)
      end

      memoize def readme
        locate_file(/^readme(\.\w+)?$/i)
      end

      private

      def locate_file(pattern)
        files.detect { |f| f.name.match?(pattern) }
          &.then { |f| contents(f.path) }
          &.then(&method(:decode_content))
      end

      def req(method, *args)
        octokit.public_send(method, repo_id, *args)
      end

      def decode_content(obj)
        # TODO: encoding is specified as a part of the answer, could it be other than base64?
        obj.merge(text: Base64.decode64(obj.fetch(:content)).force_encoding('UTF-8'))
      end

      def octokit
        self.class.octokit
      end
    end
  end
end