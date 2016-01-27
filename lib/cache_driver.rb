require "cache_driver/version"
require "cache_driver/config"
require "cache_driver/cache_record"
require "cache_driver/cache_util"
require "cache_driver/file_cache_util"

CacheDriver.config.store = :file unless CacheDriver.config.store
