require_relative '../usage_extractor'

module WhatTheGem
  # TODO
  # use Piotr's markdown formatter
  #
  # friendly report of "usage instructions not found"
  #
  # If gem not found locally -- fetch from GitHub
  #
  class Usage < Command
    register 'usage'

    TEMPLATE = Template.parse(<<~USAGE)
      {{ usage | nfirst:2 | join:"\n\n" }}
    USAGE

    def locals
      {
        usage: readme.then(&UsageExtractor.method(:new)).call
      }
    end

    private

    def readme
      local_readme || github_readme or fail "README not found"
            # abort "README not found in #{spec.gem_dir}"
    end

    def local_readme
      gem.specs.last&.gem_dir&.then(&Pathname.method(:new))&.glob('README{,.*}')&.first
    end

    def github_readme
      gem.github&.readme
    end
  end
end