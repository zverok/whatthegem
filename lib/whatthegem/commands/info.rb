module WhatTheGem
  class Info < Command
    register 'info'

    def call
      info = gem.rubygems.info
      specs = gem.specs

      # Because minitest pastes their whole README there, including a quotations of how they are
      # better than RSpec. (At the same time, RSpec's info reads "BDD for Ruby".)

      puts <<~INFO
        #{info.name} (#{[info.homepage_uri, info.source_code_uri].compact.uniq.join(', ')})

        #{info.info.split("\n\n").first}

        Latest version: #{info.version}
        Installed versions: #{specs.map(&:version).join(', ')}
        Most recent installed at: #{specs.last&.gem_dir}
      INFO
    end
  end
end