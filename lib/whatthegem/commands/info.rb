module WhatTheGem
  class Info < Command
    register 'info'

    def call
      info = gem.rubygems.info
      specs = gem.specs

      puts <<~INFO
        #{info['name']} (#{info['homepage_uri']})

        #{info['info']}

        Latest version: #{info['version']}
        Installed versions: #{specs.map(&:version).join(', ')}
        Most recent installed at: #{specs.last.gem_dir}
      INFO
    end
  end
end