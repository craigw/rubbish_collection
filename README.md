# RubbishCollection

When does my rubbish get picked up?


## Installation

Add this line to your application's Gemfile:

    gem 'rubbish_collection'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rubbish_collection


## Usage

    collection_times = RubbishCollection.times_at_postcode 'SE1 1EY'
    collection_times.each do |t|
      puts t
    end


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
