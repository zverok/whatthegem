require 'time_math'

module WhatTheGem
  class Stats
    module Definitions
      require_relative 'meters'

      def self.meters
        @meters ||= []
      end

      def self.metric(name, thresholds: nil, &block)
        meters << Meter.new(name, thresholds, block)
      end

      # TODO: Replace with TimeCalc when it'll be ready.
      # TimeMath.month.decrease(now) => TimeCalc.now.-(1, :month)
      T = TimeMath
      now = Time.now

      metric('Downloads', thresholds: [5_000, 10_000]) { gem.rubygems.info.downloads }
      metric('Latest version', thresholds: [T.year.decrease(now), T.month.decrease(now, 2)]) {
        Time.parse(gem.rubygems.versions.first.created_at)
      }
      metric('Used by', thresholds: [10, 100]) { gem.rubygems.reverse_dependencies.count }

      metric('Stars', thresholds: [100, 500]) { gem.github.repo.stargazers_count }
      metric('Forks', thresholds: [5, 20]) { gem.github.repo.forks_count }
      metric('Last commit', thresholds: [T.month.decrease(now, 4), T.month.decrease(now)]) {
        gem.github.last_commit.commit.committer.date
      }

      metric('Open issues') {
        res = gem.github.open_issues.count
        res == 50 ? '50+' : res
      }
      metric('...without reaction', thresholds: [-20, -4]) {
        gem.github.open_issues.reject { |i| i.labels.any? || i.comments.positive? }.count
      }
      metric('...last reaction', thresholds: [T.month.decrease(now), T.week.decrease(now)]) {
        gem.github.open_issues.detect { |i| i.labels.any? || i.comments.positive? }&.updated_at
      }
      metric('Closed issues') {
        res = gem.github.closed_issues.count
        res == 50 ? '50+' : res
      }
      metric('...last closed') { gem.github.closed_issues.first&.closed_at }
    end
  end
end