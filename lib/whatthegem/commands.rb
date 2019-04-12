require 'tty/markdown'
require_relative 'tty-markdown_patch'

module WhatTheGem
  class Command
    Meta = Struct.new(:handle, :title, :description, keyword_init: true)

    class << self
      memoize def registry
        {}
      end

      attr_reader :meta

      def register(title: name.split('::').last, handle: title.downcase, description:)
        Command.registry[handle] = self
        @meta = Meta.new(
          handle: handle,
          title: title,
          description: description
        )
      end

      def get(handle)
        Command.registry[handle]
      end

      def call(*args)
        new(*args).call
      end
    end

    # About info shortening: It is because minitest pastes their whole README
    # there, including a quotations of how they are better than RSpec.
    # (At the same time, RSpec's info reads "BDD for Ruby".)

    # FIXME: It was > **{{ info.info | paragraphs:1 }}** but it looks weird due to tty-markdown
    # bug: https://github.com/piotrmurach/tty-markdown/issues/11
    HEADER_TEMPLATE = Template.parse(<<~HEADER)
      # {{info.name}}
      > {{info.info | paragraphs:1 }}
      > ({{uris | join:", "}})

      ## {{title}}


    HEADER

    attr_reader :gem

    def initialize(gem)
      @gem = gem
    end

    def meta
      self.class.meta
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
        title: meta.title,
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

%w[info usage changes stats help].each { |f| require_relative(f) }