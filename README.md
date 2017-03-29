# FactoryLite

A simple gem to create factories from your own constructor functions.
Created mainly to use with Trailblazer operations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'factory-lite'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install factory-lite

## Usage

To register a new factory just define the constructor and default attributes:

```ruby
FactoryLite::Factory.register(:user) do |f|
  f.model_accessor = :trailblazer1  # assumes constructor returns model as `result.model`
  f.constructor = User::Create      # trailblazer operation

  f.default_attrs = {
    name: sequence  { |n| "User ##{n}" },
    email: sequence { |n| "user#{n}@exemple.com" },
    role: "client"
  }
end

FactoryLite::Factory.extend(:user, as: :admin_user) do |f|
  f.default_attrs = {
    role: "admin"
  }
end

FactoryLite::Factory.register(:post) do |f|
  f.model_accessor = :none           # constructor returns model directly
  f.attrs_key = nil                  # attributes passed directly to constructor
  f.constructor = lambda do |attrs|  # creating models without an operation
    Post.create!(attrs)
  end

  f.default_attrs = {
    title: sequence(1) { |n| "Post ##{n}" },
    body: "A simple post",
    author_id: ->(fac) { fac.create(:user).id }  # simple associations
  }
end

# creating models:

FactoryLite::Factory.create(:user)
FactoryLite::Factory.create(:admin_user, name: "John Doe")
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alpardal/factory_lite.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

