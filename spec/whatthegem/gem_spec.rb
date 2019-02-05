RSpec.describe WhatTheGem::Gem, :vcr do
  describe '.fetch' do
    subject { described_class.method(:fetch) }

    its_call('rubocop') { is_expected.to ret be_a(described_class).and(have_attributes(name: 'rubocop')) }
    its_call('definitelynothere') { is_expected.to ret described_class::NoGem }
  end
end