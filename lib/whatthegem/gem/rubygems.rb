module WhatTheGem
  class Gem
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
        ::Gems.public_send(method, name, *args).then(&Hm).transform_keys(&:to_sym).to_h
      end
    end
  end
end