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
      puts t.to_s
    end


## TODO

There are a lot of unsupported local authorities still. I'd very much appreciate
pull requests adding support for your local authority. See the Southwark and
Redbridge examples for how they should be structured and what the should return.

You can get the ID to register your local authority adapter against by looking
at the [local authority database][0] in my [local\_authority gem][1]. It's the
last column of the CSV row.

[0]: https://raw.github.com/craigw/local_authority/master/db/local_authorities.csv
[1]: https://github.com/craigw/local_authority

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
