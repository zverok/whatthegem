require 'kramdown'

module WhatTheGem
  # TODO:
  # more robustly ignore "installation" section or just remove gem 'foo' / gem install
  # -> select only ruby section?
  # -> remove git clone and stuff?
  #
  # use Piotr's markdown formatter
  # return header and comment
  #
  # friendly report of "usage instructions not found"
  #
  # bugs with:
  # * https://github.com/jeremyevans/sequel -- not first code example (because it is rdoc, not markdown, stupid!)
  #
  # If gem not found locally -- fetch from GitHub
  # Usage for specific version?..
  class Usage < Command
    register 'usage'

    def call
      readme
        .then { |readme| Kramdown::Document.new(readme, input: 'GFM') }
        .root.children.select { |c| c.type == :codeblock }
        .map(&:value).map(&:strip)
        .grep_v(/^(gem ['"]|gem install|bundle install|rails g |git clone|\$)/)
        .first(2)
        .join("\n\n")
        .tap(&method(:puts))
    end

    private

    def readme
      local_readme || github_readme or abort "README not found"
            # abort "README not found in #{spec.gem_dir}"
    end

    def local_readme
      gem.specs.last&.gem_dir&.then(&Pathname.method(:new))&.glob('README{,.*}')&.first&.read
    end

    def github_readme
      gem.github&.readme&.text
    end
  end
end