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

    address = OpenStruct.new :house_number => "2",
      :street_name => "Beech Road", :postcode => "GU14 8EU"
    collection_times = RubbishCollection.times_at_address address
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

Note that the API of the address object used in this gem hasn't yet been settled
on. Different local authorities need different parts or formats of the address
to determine collection times eg Southwark and Redbridge are pretty good with
just the postcode but Westminster need a street name. At some point we should
either find a gem that already caters to addresses and provides a nice API and
tools for comparison, or we should define or own.

Not all local authorities perform all collections on a weekly basis -
[fuzzmonkey][2] points out that Rushmoor only pick up recycling once a
fortnight. This project can't handle schedules like that yet. Perhaps we
should consider pulling in a more advanced temporal event library?

  * [Recurring Event][3]
  * [RUNT][4]

[0]: https://raw.github.com/craigw/local_authority/master/db/local_authorities.csv
[1]: https://github.com/craigw/local_authority
[2]: https://github.com/fuzzmonkey
[3]: https://github.com/nickstenning/recurring_event
[4]: https://github.com/texel/runt


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
