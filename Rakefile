$LOAD_PATH.unshift 'lib'
require 'pathname'

namespace :dev do
  desc 'Fetch changelogs for tests'
  task :changelogs do
    require 'whatthegem'
    dir = Pathname.new('spec/fixtures/changelogs')
    dir./('list.txt').read.split("\n").grep_v(/^\#/)
      .reject { |name| dir.glob("#{name}__*{,.*}").any? }
      .each do |name|
        puts "Fetching for #{name}"
        unless (changelog = WhatTheGem::Gem.new(name).github.changelog)
          puts "Not found"
          next
        end
        path = dir / "#{name}__#{changelog.name}"
        puts "Found #{changelog.name}, writing to #{path}"
        path.write(changelog.text)
      end
  end
end