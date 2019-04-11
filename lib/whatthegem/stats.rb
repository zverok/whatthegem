module WhatTheGem
  class Stats < Command
    register description: 'Gem freshness and popularity stats'

    def output
      Definitions.meters.map { |meter| meter.call(gem).format }.join("\n")
    end
  end
end

require_relative 'stats/meters'
require_relative 'stats/definitions'
