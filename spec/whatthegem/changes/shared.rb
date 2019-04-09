RSpec.shared_context 'parse changelog' do
  let(:file) { changelog(gem_name) }

  subject(:versions) { described_class.call(file) }
end

RSpec.shared_examples 'parses successfully' do |name|
  context "with #{name} -- sanity tests" do
    let(:gem_name) { name }
    include_context 'parse changelog'

    it { is_expected.to all be_a WhatTheGem::Changes::Version }
    its(:count) { is_expected.to be > 10 }
    its_map(:'number.to_s') { is_expected.to all match /^\d+\.\d+(\.\d+(\.\w+)?)?$/ }
  end
end

RSpec.shared_examples 'parses changelog' do |name, versions:|
  context "with #{name} -- full tests" do
    let(:gem_name) { name }
    include_context 'parse changelog'

    its_map(:'number.to_s') { are_expected.to end_with versions.reverse }
  end
end
