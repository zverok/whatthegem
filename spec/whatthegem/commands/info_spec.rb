RSpec.describe WhatTheGem::Info do
  describe '#locals', :vcr do
    subject { ->(gem_name) { described_class.new(WhatTheGem::Gem.new(gem_name)).locals } }

    its_call('rubocop') {
      is_expected.to ret hash_including(
        info: hash_including(
          name: 'rubocop',
          info: "    Automatic Ruby code style checking tool.\n    Aims to enforce the community-driven Ruby Style Guide.\n"
        ),
        uris: %w[https://github.com/rubocop-hq/rubocop/ https://www.rubocop.org/],
      )
    }

    context 'with specs available' do
      let(:specs) {
        [
          instance_double('::Gem::Specification', name: 'rubocop', version: ::Gem::Version.new('0.46.0'), gem_dir: '/gems/rubocop-0.46.0'),
          instance_double('::Gem::Specification', name: 'rubocop', version: ::Gem::Version.new('0.58.0'), gem_dir: '/gems/rubocop-0.58.0'),
        ]
      }
      before {
        # in specs context, gem specifications list what's in bundle,
        # but in app context everything'll be OK
        allow(::Gem::Specification).to receive(:select).and_return(specs)
      }

      its_call('rubocop') {
        is_expected.to ret hash_including(
          specs: [hash_including(version: '0.46.0'), hash_including(version: '0.58.0')],
          current: hash_including(version: '0.58.0')
        )
      }
    end
  end
end