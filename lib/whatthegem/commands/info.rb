module WhatTheGem
  class Info < Command
    register 'info'

    # About info shortening: It is because minitest pastes their whole README
    # there, including a quotations of how they are better than RSpec.
    # (At the same time, RSpec's info reads "BDD for Ruby".)

    TEMPLATE = Template.parse(<<~INFO)
                Latest version: {{info.version}} ({{age}})
            Installed versions: {% if specs %}{{ specs | map:"version" | join: ", "}}{% else %}—{% endif %}
      {% if current %}
      Most recent installed at: {{current.dir}}
      {% endif %}
      {% unless bundled.type == 'nobundle' %}
                In your bundle: {% if bundled.type == 'notbundled' %}—{% else
      %}{{ bundled.version }} at {{ bundled.dir }}{% endif %}
      {% endunless %}
    INFO

    def locals
      {
        info: gem.rubygems.info,
        age: age,
        specs: specs,
        current: specs.last,
        bundled: gem.bundled.to_h
      }
    end

    private

    def age
      gem.rubygems.versions
        .first&.dig(:created_at)
        &.then(&Time.method(:parse))&.then(&I.method(:ago_text))
    end

    def specs
      gem.specs.map { |spec|
        {
          name: spec.name,
          version: spec.version.to_s,
          dir: spec.gem_dir
        }
      }
    end
  end
end