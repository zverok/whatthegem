require 'gems'
require 'octokit'

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

      def initialize(repo_id)
        @repo_id = repo_id
      end
    end

    class RubyGems
      attr_reader :name

      def initialize(name)
        @name = name
      end

      memoize def info
        ::Gems.info(name)
      rescue JSON::ParserError => e
        # Gems have no cleaner way to indicate gem does not exist :shrug:
        raise unless e.message.include?('This rubygem could not be found.')
        abort("Gem #{name} does not exist.")
      end

      memoize def versions
        ::Gems.versions(name)
      end

      memoize def reverse_dependencies
        ::Gems.reverse_dependencies(name)
      end
    end

    attr_reader :name

    def initialize(name)
      @name = name
    end

    memoize def rubygems
      RubyGems.new(name)
    end

    memoize def github
      rubygems.info.values_at('source_code_uri', 'homepage_uri')
        .yield_self(&method(:detect_repo_id))
        &.yield_self(&GitHub.method(:new))
    end

    memoize def specs
      ::Gem::Specification.select { |s| s.name == name }.sort_by(&:version)
    end
  end
end