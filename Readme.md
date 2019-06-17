# Rack::Attack Admin Dashboard  [![Gem Version](https://badge.fury.io/rb/rack_attack_admin.svg)](https://badge.fury.io/rb/rack_attack_admin)

Lets you see the current state of all throttles and bans. Delete existing keys/bans. Manually add bans.

Inspired by: https://www.backerkit.com/blog/building-a-rackattack-dashboard/

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'rack_attack_admin'
```

And then execute:

    $ bundle


Add this line to your application's `config/routes.rb`:

```ruby
mount RackAttackAdmin::Engine, at: '/admin/rack_attack'
```

## Usage

Go to '/admin/rack_attack' in your browser!

## Compatibility

This has mostly been tested with `Rack::Attack.cache.store` set to an instance
of Redis::Store from the fantastic
[redis-store](https://github.com/redis-store/redis-store) gem. (Used by
ActiveSupport::Cache::RedisStore (from redis-activesupport gem))

Now that Rails 5.2+ provides its own built-in `ActiveSupport::Cache::RedisCacheStore`, you may set
`Rack::Attack.cache.store` to an instance of that store instead.

However, if you are using the `namespace` option, it won't be able to find/list the keys, because
`ActiveSupport::Cache::RedisCacheStore` doesn't provide a nice way to get the list of keys like
`Redis::Store` provides (`cache.data.keys`). It will currently use `cache.redis.keys` but that
(`Redis#keys`) leaves the namespace as a prefix in the keys it returns, and there doesn't appear to
be a clean way to get the keys without namespace.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TylerRick/rack_attack_admin.
