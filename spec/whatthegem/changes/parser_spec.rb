RSpec.describe WhatTheGem::Changes::Parser do
  # shared_context 'parses changelog' do |gem_name, versions: nil, latest: nil, by_version: {}|

  # end

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

  let(:fixtures) { Pathname.new('spec/fixtures/changelogs') }

  shared_examples 'parses successfully' do |gem_name|
    context "with #{gem_name}" do
      let(:path) { fixtures.glob("#{gem_name}__*{,.*}").first }
      let(:content) { path.read }

      subject(:versions) { described_class.call(path.basename, content) }

      it { is_expected.to all be_a described_class::Version }
      # its(:count) { is_expected.to be > 10 }
      # its_map(:number) { is_expected.to all match /^\d+\.\d+(\.\d+)?$/ }
    end
  end

  include_examples 'parses successfully', 'rubocop'
end