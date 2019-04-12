require 'ripper'

module WhatTheGem
  class Usage
    # TODO:
    # more robustly ignore "installation" section or just remove gem 'foo' / gem install
    # -> select only ```ruby section from markdown (if they exist)?
    # -> more removal patterns? Like `rake something`
    #
    class Extractor
      REMOVE_BLOCKS = [
        %{gem ['"]},      # gem install instructions
        'gem install',
        'bundle install',
        'rake ',

        'rails g ',       # rails generator
        'git clone',      # instructions to contribute

        '\\$',            # bash command
        'ruby (\S+)$',    # run one Ruby command

        'Copyright '      # Sometimes they render license in ```
      ]

      REMOVE_BLOCKS_RE = /^#{REMOVE_BLOCKS.join('|')}/

      extend I::Callable

      class CodeBlock < Struct.new(:body)
        def initialize(body)
          super(try_sanitize(body))
        end

        def ruby?
          # Ripper returns nil for anything but correct Ruby
          #
          # TODO: Unfortunately, Ripper is fixed to current version syntax, so trying this trick on
          # Ruby 2.4 with something that uses Ruby 2.7 features will unhelpfully return "no, not Ruby"
          #
          # Maybe trying parser gem could lead to the same effect
          !Ripper.sexp(body).nil?
        end

        def service?
          body.match?(REMOVE_BLOCKS_RE)
        end

        def to_h
          {body: body}
        end

        private

        def try_sanitize(text)
          text
            .gsub(/^>> /, '')                   # Imitating work from IRB, TODO: various IRB/Pry patterns
            .gsub(/^(=> )/, '# \\1')            # Output in IRB, should be hidden as comment
            .gsub(/^(Results: )/, '# \\1')      # Output, in some gems
            .gsub(/^( *)(\.{2,})/, '\\1# \\2')  # "...and so on..." in code examples
        end
      end

      def self.call(file)
        new(file).call
      end

      def initialize(file)
        @file = file
      end

      def call
        code_blocks(file.read).map(&CodeBlock.method(:new)).reject(&:service?).select(&:ruby?)
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
end