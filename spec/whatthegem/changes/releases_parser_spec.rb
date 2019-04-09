require_relative 'shared'

RSpec.describe WhatTheGem::Changes::ReleasesParser do
  def changelog(name)
    VCR.use_cassette("changelog/#{name}-releases") do
      WhatTheGem::Gem.new(name).github.releases
    end
  end

  include_examples 'parses successfully', 'faraday'
end
