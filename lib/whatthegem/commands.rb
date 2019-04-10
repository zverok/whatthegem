require 'tty/markdown'
require_relative 'tty-markdown_patch'

module WhatTheGem
  class Command
    class << self
      memoize def registry
        {}
      end

      def register(name)
        Command.registry[name] = self
      end

      def fetch(name)
        Command.registry.fetch(name)
      end

      def call(*args)
        new(*args).call
      end
    end

    # About info shortening: It is because minitest pastes their whole README
    # there, including a quotations of how they are better than RSpec.
    # (At the same time, RSpec's info reads "BDD for Ruby".)

    HEADER_TEMPLATE = Template.parse(<<~HEADER)
      # {{info.name}} ({{uris | join:", "}})

      **{{info.info | paragraphs:1 }}**


    HEADER

    attr_reader :gem

    def initialize(gem)
      @gem = gem
    end

    def call
      puts full_output
    end

    private

    def full_output
      gm = gem # otherwise next line breaks Sublime highlighting...
      return %{Gem "#{gm.name}" is not registered at rubygems.org.} unless gem.exists?
      header_locals.then(&HEADER_TEMPLATE).then(&method(:markdown)) + output
    end

    def output
      locals.then(&template)
    end

    def header_locals
      {
        info: gem.rubygems.info,
        uris: guess_uris(gem.rubygems.info),
      }
    end

    def markdown(text)
      TTY::Markdown.parse(text)
    end

    def template
      self.class::TEMPLATE
    end

    def guess_uris(info)
      [
        info[:source_code_uri],
        info.values_at(:homepage_uri, :documentation_uri, :project_uri).compact.reject(&:empty?).first
      ]
      .compact.reject(&:empty?).uniq { |u| u.chomp('/').sub('http:', 'https:') }
    end
  end
end

Dir[File.expand_path('./commands/*.rb', __dir__)].each(&method(:require))