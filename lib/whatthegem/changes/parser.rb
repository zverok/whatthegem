module WhatTheGem
  class Changes
    class Parser
      extend I::Callable

      class << self
        def call(file)
          parser_for(file).versions
        end

        def parser_for(file)
          case file.basename
          when /\.(md|markdown)$/i
            MarkdownParser.new(file)
          else
            fail ArgumentError, "Don't know how to parse #{file.basename}"
          end
        end
      end

      attr_reader :file

      def initialize(file)
        @file = file
      end

      memoize def versions
        fail NotImplementedError
      end

      private

      memoize def content
        file.read
      end
    end
  end
end

require_relative 'markdown_parser'