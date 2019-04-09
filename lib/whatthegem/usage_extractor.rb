require 'rdoc'

module WhatTheGem
  # TODO:
  # more robustly ignore "installation" section or just remove gem 'foo' / gem install
  # -> select only ```ruby section from markdown (if they exist)?
  # -> more removal patterns? Like `rake something`
  #
  class UsageExtractor
    REMOVE_BLOCKS = [
      %{gem ['"]},      # gem install instructions
      'gem install',
      'bundle install',

      'rails g ',       # rails generator
      'git clone',      # instructions to contribute

      '\\$',            # bash command
      'ruby (\S+)$',    # run one Ruby command

      'Copyright '      # Sometimes they render license in ```
    ]

    REMOVE_BLOCKS_RE = /^#{REMOVE_BLOCKS.join('|')}/

    def initialize(file)
      @file = file
    end

    def call
      code_blocks(file.read).grep_v(REMOVE_BLOCKS_RE)
    end

    private

    attr_reader :file

    memoize def format
      case file.basename.to_s
      when /\.(md|markdown)$/i
        :markdown
      else
        :rdoc
      end
    end

    def code_blocks(content)
      __send__("#{format}_code_blocks", content)
    end

    def markdown_code_blocks(content)
      I::Kramdowns.elements(content)
        .select { |c| c.type == :codeblock }
        .map(&:value).map(&:strip)
    end

    def rdoc_code_blocks(content)
      I::RDocs.parts(content).grep(RDoc::Markup::Verbatim).map(&:text)
    end
  end
end