RSpec.describe WhatTheGem::Usage::Extractor do
  def readme(name)
    VCR.use_cassette("readme/#{name}") do
      WhatTheGem::Gem.new(name).github.readme
    end
  end

  shared_examples 'extract usage' do |gemname, *blocks|
    context "for #{gemname}" do
      let(:file) { readme(gemname) }

      subject { described_class.new(file).call }

      it {
        is_expected.to start_with blocks.map(&method(:start_with))
      }
    end
  end

  it_behaves_like 'extract usage',
    'faraday',
    "response = Faraday.get 'http://sushi.com/nigiri/sake.json'",
    "conn = Faraday.new(:url => 'http://www.example.com')\n" \
    "response = conn.get '/users'                 # GET http://www.example.com/users'"

  it_behaves_like 'extract usage',
    'sequel',
    %q{
      require 'sequel'

      DB = Sequel.sqlite # memory database, requires sqlite3

      DB.create_table :items do
        primary_key :id
        String :name
        Float :price
      end

      items = DB[:items] # Create a dataset

      # Populate the table
      items.insert(:name => 'abc', :price => rand * 100)
      items.insert(:name => 'def', :price => rand * 100)
      items.insert(:name => 'ghi', :price => rand * 100)

      # Print out the number of records
      puts "Item count: #{items.count}"

      # Print out the average price
      puts "The average price is: #{items.avg(:price)}"
    }.squig

  it_behaves_like 'extract usage',
    'sinatra',
    '# myapp.rb',
    "get '/' do"
end