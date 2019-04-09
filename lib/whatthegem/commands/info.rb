module WhatTheGem
  class Info < Command
    register 'info'

    # About info shortening: It is because minitest pastes their whole README
    # there, including a quotations of how they are better than RSpec.
    # (At the same time, RSpec's info reads "BDD for Ruby".)
    # TODO: filter `paragraphs: 1`

    TEMPLATE = Template.parse(<<~INFO)
      {{info.name}} ({{uris | join:", "}})

      {{info.info | paragraphs:1 }}

      Latest version: {{info.version}}
      Installed versions: {% if specs %}{{ specs | map:"version" | join: ", "}}{% else %}—{% endif %}
      {% if current %}Most recent installed at: {{current.dir}}{% endif %}
      {% unless bundled.type == 'nobundle' %}In your bundle: {% if bundled.type == 'notbundled' %}—{% else
      %}{{ bundled.version }} at {{ bundled.dir }}{% endif %}{% endunless %}
    INFO

    def locals
      {
        info: gem.rubygems.info,
        uris: guess_uris(gem.rubygems.info),
        specs: specs,
        current: specs.last,
        bundled: gem.bundled.to_h
      }
    end

    private

    def specs
      gem.specs.map { |spec|
        {
          name: spec.name,
          version: spec.version.to_s,
          dir: spec.gem_dir
        }
      }
    end

    def guess_uris(info)
      [
        info[:source_code_uri],
        info.values_at(:homepage_uri, :documentation_uri, :project_uri).compact.reject(&:empty?).first
      ]
      .compact.reject(&:empty?).uniq { |u| u.chomp('/').sub('http:', 'https:') }
    end
  end
end