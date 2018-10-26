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

  let(:fixtures) { Pathname.new('spec/fixtures/changelogs') }

  shared_context 'parse changelog' do
    let(:path) { fixtures.glob("#{gem_name}__*{,.*}").first }
    let(:content) { path.read }

    subject(:versions) { described_class.call(path.basename, content) }
  end

  shared_examples 'parses successfully' do |name|
    context "with #{name} -- sanity tests" do
      let(:gem_name) { name }
      include_context 'parse changelog'

      it { is_expected.to all be_a described_class::Version }
      its(:count) { is_expected.to be > 10 }
      its_map(:'number.to_s') { is_expected.to all match /^\d+\.\d+(\.\d+)?$/ }
    end
  end

  shared_examples 'parses changelog' do |name, versions:|
    context "with #{name} -- full tests" do
      let(:gem_name) { name }
      include_context 'parse changelog'

      its_map(:'number.to_s') { are_expected.to end_with versions.reverse }
    end
  end

  include_examples 'parses successfully', 'rubocop'
  include_examples 'parses successfully', 'faker'
  include_examples 'parses changelog', 'vcr', versions: %w[4.0.0 3.0.3 3.0.2]
  # warden: fallback to just text parse, they have weird "== Version 1.2.3", which is not markdown
end