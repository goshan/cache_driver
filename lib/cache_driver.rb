require "redis"

require "cache_driver/version"
require "cache_driver/config"
require "cache_driver/cache_record"
require "cache_driver/cache_util"
require "cache_driver/file_cache_util"
require "cache_driver/redis_cache_util"


module CacheDriver
  class Railtie < ::Rails::Railtie
    rake_tasks do 
      load 'tasks/cache.rake'
    end
  end
end

unless CacheDriver.configed?
  CacheDriver.setup do |config|
    config.store = :file
  end
end
