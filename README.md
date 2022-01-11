# Imyou

[![Test](https://github.com/patorash/imyou/actions/workflows/test.yml/badge.svg)](https://github.com/patorash/imyou/actions/workflows/test.yml)

Imyou has feature of attaching popular name to ActiveRecord model.

Imyou mean nickname in japanese.

## Installation

### Rails 5.x, 6.x and 7.0.x

Add this line to your application's Gemfile:

```ruby
gem 'imyou'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install imyou

### Database Migrations

Imyou uses a imyou_nicknames table to store popular names information.
To generate and run the migration just use.

    $ rails generate imyou:migration
    $ rails db:migrate

## Usage

```ruby
class User < ApplicationRecord
  has_imyou 
end

class Book < ApplicationRecord
  has_imyou :title # add search target column
end

@user = User.new(name: 'hoge')
@book = Book.new(title: 'book')

# Add nickname.
@user.add_nickname('foo')
@user.nicknames # => ['foo']

@book.add_nickname('red')
@book.nicknames # => ['red']

# Add nicknames by Array.
@user.nicknames = %w(foo bar baz)
@user.nicknames # => ['foo', 'bar', 'baz']

@book.nicknames = %w(red green blue)
@book.nicknames # => ['red', 'green', 'blue']

# preload
User.with_nicknames

# Search users by nickname.
User.match_by_nickname('hoge').exists? # => false
User.match_by_nickname('baz').exists? # => true
User.match_by_nickname('ba').exists?  # => false

User.partial_match_by_nickname('ho').exists? # => true
User.partial_match_by_nickname('baz').exists? # => true
User.partial_match_by_nickname('ba').exists?  # => true

# Search books by nickname.
Book.match_by_nickname('book').exists? # => true 
Book.match_by_nickname('book', with_name_column: false).exists? # => false 
Book.match_by_nickname('red').exists? # => true 
Book.match_by_nickname('yellow').exists? # => false 

Book.partial_match_by_nickname('bo').exists? # => true 
Book.partial_match_by_nickname('bo', with_name_column: false).exists? # => false 
Book.partial_match_by_nickname('re').exists? # => true 

# Remove nickname.
@user.remove_nickname('foo')
@user.nicknames # => ['bar', 'baz']

# Remove all nicknames.
@user.remove_all_nicknames
@user.nicknames # => []
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/patorash/imyou. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Imyou project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/imyou/blob/master/CODE_OF_CONDUCT.md).
