# CacheDriver

This gem makes rails model act as ActiveRecord, but not save data into database but cache system, file or redis

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cache_driver'
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

cache_model = CacheModel.find_by_key key  # get instance with key

cache_model.save!  # save this instance to cache

cache_model.destroy  # delete this instance
```

Also you can customize the data which you want to cache. 
Just override the two methods below

```ruby
def to_cache
  # return a hashmap which you want to cache for this model
end

def self.from_cache(obj)
  # return this model instance from a hashmap obj include data you cached
end
```

## Cache Inspect

Sometimes you need know the data detail in cache, So you can use a rake task supported by us.

	$ bundel exec rake cache:inspect

Use the the command above to go to cache inspector and you will see the information below

	CacheDriver > 

After this you can use the following six commands to do something with the cache set by current project

```sql
CacheDriver > show models
CacheDriver > desc <model>
CacheDriver > select from <model> (where id=<id>)
CacheDriver > insert to <model> values {'id' => 1, ...}
CacheDriver > delete from <model> where id=<id>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/goshan/cache_driver.  


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

