# CacheDriver

This gem makes rails model act as ActiveRecord, but not save data into database but cache system, file or redis

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cache_driver', '~> 0.3'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cache_driver

## Usage

Add following code to environments/development.rb or environments/production.rb  

```ruby
CacheDriver.setup do |config|
  # set cache store type, :file or :redis
  config.store = :file
  config.file_dir = Rails.root.join('tmp', 'cache')
  #config.store = :redis
  #config.redis_host = "127.0.0.1"
  #config.redis_port = 6379
  #config.redis_namespace = "namespace"
end
```

And then, create a model file in `app/models`  

    $ touch app/models/cache_model.rb

Just define model like below  

```ruby
class CacheModel < CacheRecord
  # attribute name which is made as key to cache data
  def self.key_attr
    "attr_name"
  end
end
```

So you can use this model just like other ActiveRecord instance in controllers like

```ruby
cache_models = CacheModel.find_all  # get all instance in cache  

cache_model = CacheModel.find_by_key key  # get instance which has key_attr

cache_model = CacheModel.find_current  # get instance which has no key_attr

CacheModel.clear  # remove all cache

cache_model.save  # save this instance to cache

cache_model.destroy  # delete this instance
```

By default, the attribute `Fixnum`, `String`, `Array`, `Hash` will be serialized to cache. But you should declare how to process other object such as Symbol or Class you creates
So you can customize the serialization method to change data which you want to cache by overriding the two methods below

```ruby
def to_cache
  # super will process Fixnum, String, Array, Hash and return a new HashMap to use for serialization
  # do other work with this hash to customize way of serialization
  # return a hashmap which you want to cache for this model
  hash = super
end

def self.from_cache(obj)
  # super will return a new instance for this class from a HashMap named `obj` which unserialized from cache, and the key of HashMap is String not Symbol.
  # Only Fixnum, String, Array, Hash can be unserialized into HashMapexactly
  # do other work with this new instance to customize way of unserialization
  # return a instance of this Class which is unserialized from cache
  ins = super obj
end
```

## Cache Inspect

Sometimes you need know the data detail in cache, So you can use a rake task supported by us.

	$ bundel exec rake cache:inspect

Use the the command above to go to cache inspector and you will see the information below

	CacheDriver > 

After this you can use the following six commands to do something with the cache set by current project

```sql
CacheDriver > ?  # show all commands and descriptions
CacheDriver > show models
CacheDriver > show keys <model>
CacheDriver > find <model> in <key>
CacheDriver > save <model> to <key> withs <attr1>=<val1>,<attr2>=<val2>,...
CacheDriver > delete <model> in <key>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/goshan/cache_driver.  


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

