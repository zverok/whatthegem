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
  # * https://github.com/jeremyevans/sequel -- not first code example
  #
  # If gem not found locally -- fetch from GitHub
  # Usage for specific version?..
  class Usage < Command
    register 'usage'

    def call
      gem.specs.last
        .then { |spec|
          Dir[File.join(spec.gem_dir, 'README{,.*}')].first or
            abort "README not found in #{spec.gem_dir}"
        }
        .then { |readme| Kramdown::Document.new(File.read(readme), input: 'GFM') }
        .root.children.select { |c| c.type == :codeblock }
        .map(&:value).map(&:strip)
        .grep_v(/^(gem ['"]|gem install|bundle install|\$)/)
        .first(2)
        .join("\n\n")
        .tap(&method(:puts))
    end
  end
end