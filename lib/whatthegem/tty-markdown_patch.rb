module WhatTheGem
  module TTYMarkdownPatch
    def convert_br(el, opts)
      opts[:result] << "\n"
    end
  end

  ::TTY::Markdown::Parser.include TTYMarkdownPatch
end