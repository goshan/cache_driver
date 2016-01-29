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

Your can create a config file to set storage type  

    $ touch config/initializers/cache_driver.rb

```ruby
# CacheDriver Config
# to make model save data to file or redis not database

CacheDriver.setup do |config|
	# set cache store type, :file or :redis
	# default is :file
	config.store = :file
end
```

And then, create a model file in `app/models`  

    $ touch app/models/cache_model.rb

Just define model like below  

```ruby
class CacheModel < CacheRecord
end
```

So you can use this model just like other ActiveRecord instance in controllers like

```ruby
cache_models = CacheModel.find_all  # get all instance in cache  

cache_model = CacheModel.find_by_id params[:id]  # get instance with id

cache_model.save!  # save this instance to cache

cache_model.destroy  # delete this instance
```

Also you can customize the data which you want to cache. 
Just override the two methods below

```ruby
def to_cache
  # do something you want to cache this model
end

def self.from_cache
  # do something you want to get model from cache
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/goshan/cache_driver.  


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

