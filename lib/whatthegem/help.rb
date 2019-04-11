module WhatTheGem
  class Help < Command
    TEMPLATE = Template.parse(<<~HELP)
      `whatthegem` is a small tool for fetching information about Ruby gems from various sources.

      **Usage:** `whatthegem <gemname> [<command>]`

      Known commands:
      {% for command in commands %}
      * `{{command.handle}}`: {{command.description}}{% endfor %}
    HELP

    def initialize(*)
    end

    def locals
      {commands: commands}
    end

    private

    def full_output
      markdown output
    end

    def commands
      Command.registry.values.map(&:meta).map(&:to_h)
    end
  end
end