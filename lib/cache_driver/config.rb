module CacheDriver
  class Config
    attr_accessor :store, :file_dir, :redis_host, :redis_port, :redis_namespace
  end

  @@config = Config.new

  def self.config
    @@config
  end

  def self.configed?
    @@config.store
  end

  def self.store_file?
    @@config.store == :file
  end

  def self.store_redis?
    @@config.store == :redis
  end

  def self.setup
    yield @@config
  end

end
