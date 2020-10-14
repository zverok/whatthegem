module WhatTheGem
  class Info < Command
    register description: '(default) General information about the gem'

    # About info shortening: It is because minitest pastes their whole README
    # there, including a quotations of how they are better than RSpec.
    # (At the same time, RSpec's info reads "BDD for Ruby".)

    TEMPLATE = Template.parse(<<~INFO)
                Latest version: {{info.version}} ({{age}})
      {% if prerelease %}
                    Prerelease: {{prerelease.number}} ({{prerelease.age}})
      {% endif %}
            Installed versions: {% if specs %}{{ specs | map:"version" | join: ", "}}{% else %}—{% endif %}
      {% if current %}
      Most recent installed at: {{current.dir}}
      {% endif %}
      {% unless bundled.type == 'nobundle' %}
                In your bundle: {% if bundled.type == 'notbundled' %}—{% else
      %}{{ bundled.version }} at {{ bundled.dir }}{% endif %}
      {% endunless %}

      Try also:
      {% for command in commands %}
        `whatthegem {{info.name}} {{command.handle}}` -- {{command.description}}{% endfor %}
    INFO

    def locals
      {
        info: gem.rubygems.info,
        age: age,
        prerelease: prerelease,
        specs: specs,
        current: specs.last,
        bundled: gem.bundled.to_h,
        commands: commands
      }
    end

    private

    def age
      version = gem.rubygems.stable_versions.first or return
      version.dig(:created_at).then(&Time.method(:parse)).then(&I.method(:ago_text))
    end

    def prerelease
      gem.rubygems.versions.first
        &.then { |ver| ver if ver[:prerelease] }
        &.then { |ver| ver.merge(age: I.ago_text(Time.parse(ver[:created_at]))) }
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

    def commands
      Command.registry.values.-([self.class]).map(&:meta).map(&:to_h)
    end
  end
end
