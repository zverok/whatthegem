require 'rspec/its'
require 'saharspec'
require 'webmock'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

require 'whatthegem'

class String
  def squig
    res = rstrip
    remove = res.scan(/^( +)/).flatten.map(&:length).min
    res.gsub(/^ {#{remove}}/, '').strip
  end
end