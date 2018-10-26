module WhatTheGem
  # TODO: which versions to output:
  # * not installed locally: just last and last major
  # * installed locally: everything since installed locally
  # * installed locally and fresh: last
  class Changes < Command
    register 'changes'

    def call
      return if !versions || versions.empty?

      puts versions.last.header
      puts
      puts versions.last.body
    end

    private

    memoize def versions
      gem.github # always take the freshest from GitHub, even when installed locally
        &.changelog
        &.then { |file| Parser.call(file.name, file.text) }
    end
  end
end

require_relative 'changes/parser'