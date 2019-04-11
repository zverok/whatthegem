module WhatTheGem
  # TODO
  # use Piotr's markdown formatter
  #
  # friendly report of "usage instructions not found"
  #
  # If gem not found locally -- fetch from GitHub
  #
  class Usage < Command
    register description: 'Gem usage examples'

    TEMPLATE = Template.parse(<<~USAGE)
      {% for u in usage %}
      {{ u.body | rouge }}
      {% endfor %}
    USAGE

    def locals
      {
        usage: readme.then(&Extractor).first(2).map(&:to_h)
      }
    end

    private

    def readme
      local_readme || github_readme or fail "README not found"
      # better?.. "README not found in #{spec.gem_dir}"
    end

    def local_readme
      gem.specs.last&.gem_dir&.then(&Pathname.method(:new))&.glob('README{,.*}')&.first
    end

    def github_readme
      gem.github&.readme
    end
  end
end

require_relative 'usage/extractor'
