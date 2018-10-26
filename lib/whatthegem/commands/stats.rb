module WhatTheGem
  class Stats < Command
    register 'stats'

    def call
      Definitions.meters.each do |meter|
        puts meter.call(gem).format
      end
    end
  end
end

require_relative 'stats/meters'
require_relative 'stats/definitions'
