require 'time_math'

module WhatTheGem
  class Stats
    module Definitions
      require_relative 'meters'

      FIFTY_PLUS = proc { |res| res == 50 ? '50+' : res }
      HAS_REACTION = proc { |i| i[:labels].any? || i[:comments].positive? }

      def self.meters
        @meters ||= []
      end

      def self.metric(name, *path, thresholds: nil, &block)
        meters << Meter.new(name, path, thresholds, block || :itself.to_proc)
      end

      # TODO: Replace with TimeCalc when it'll be ready.
      # TimeMath.month.decrease(now) => TimeCalc.now.-(1, :month)
      T = TimeMath
      now = Time.now

      metric 'Downloads', :rubygems, :info, :downloads, thresholds: [5_000, 10_000]
      metric 'Latest version',
        :rubygems, :versions, 0, :created_at,
        thresholds: [T.year.decrease(now), T.month.decrease(now, 2)],
        &Time.method(:parse)

      metric 'Dependents', :rubygems, :reverse_dependencies, :count, thresholds: [10, 100]

      metric 'Stars', :github, :repo, :stargazers_count, thresholds: [100, 500]
      metric 'Forks', :github, :repo, :forks_count, thresholds: [5, 20]
      metric 'Last commit',
        :github, :last_commit, :commit, :committer, :date,
        thresholds: [T.month.decrease(now, 4), T.month.decrease(now)]

      metric('Open issues', :github, :open_issues, :count, &FIFTY_PLUS)
      metric('...without reaction', :github, :open_issues, thresholds: [-20, -4]) { |issues|
        issues.reject(&HAS_REACTION).count
      }
      metric('...last reaction',
        :github, :open_issues,
        thresholds: [T.month.decrease(now), T.week.decrease(now)]
      ) { |issues| issues.detect(&HAS_REACTION)&.dig(:updated_at) }
      metric('Closed issues', :github, :closed_issues, :count, &FIFTY_PLUS)
      metric '...last closed', :github, :closed_issues, 0, :closed_at
    end
  end
end
