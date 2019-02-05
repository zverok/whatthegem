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

    attr_reader :gem

    def initialize(gem)
      @gem = gem
    end
  end
end

Dir[File.expand_path('./commands/*.rb', __dir__)].each(&method(:require))