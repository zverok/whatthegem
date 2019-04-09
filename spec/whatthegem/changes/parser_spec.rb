require_relative 'shared'

RSpec.describe WhatTheGem::Changes::Parser do
  # it_behaves_like 'parses changelog', 'sequel',
  #   versions: %w[5.13.0 5.12.0 5.11.0 5.10.0 ...],
  #   latest: <<~CHANGES,
  #     * Support :single_value type in prepared statements (rintaun) (#1547)

  #     * Make Model.all in static_cache plugin accept a block (AlexWayfer, jeremyevans) (#1543)
  #   CHANGES
  #   by_version: {
  #     '4.1.0' => <<~CHANGES
  #       * Support :inherits option in Database#create_table on PostgreSQL, for table inheritance (jeremyevans)

  #       * Handle dropping indexes for schema qualified tables on PostgreSQL (jeremyevans)
  #     CHANGES
  #   }

  def changelog(name)
    VCR.use_cassette("changelog/#{name}") do
      WhatTheGem::Gem.new(name).github.changelog
    end
  end

  let(:fixtures) { Pathname.new('spec/fixtures/changelogs') }

  include_examples 'parses successfully', 'rubocop'
  include_examples 'parses successfully', 'faker'
  include_examples 'parses changelog', 'tzinfo', versions: %w[2.0.0 1.2.5 1.2.4 1.2.3]
  include_examples 'parses changelog', 'vcr', versions: %w[4.0.0 3.0.3 3.0.2]

  # More examples:
  # sinatra
  # sequel
  # timecop
  # yard
  # wicked_pdf
  # ruby-prof
  # rake
  # prawn
  # google-api-client
  # geocoder
  # dotenv
  # coffee-rails
  # concurrent-ruby
  # draper

  # Complicated:
  # factory_bot -- NEWS, plaintext file
  # sassc-ruby: just list in markdown, no headers
  # ? warden: fallback to just text parse, they have weird "== Version 1.2.3", which is not markdown

  # GH releases:
  # faraday
  # octokit
  # minimagick

  # activerecord -- complex GH URL

  # Unfixable:
  # sass -- just don't has it. At all
  # kramdown -- custom site, impossible (?) to support
  # rspec -- meta-gem
end