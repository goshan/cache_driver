class RedisCacheUtil < CacheUtil

  class << self
    def write(type, key, data)
      super type, key, data

      res = redis.set "#{namespace}:#{type_to_dir(type)}##{key}", "#{Time.now} --> #{data.to_cache.to_json}"
      res == "OK" ? key : nil
    end

    def read(type, key)
      super type, key

      content = redis.get("#{namespace}:#{type_to_dir(type)}##{key}")
      unless content
        puts "cache #{type} ##{key} data miss"
        return nil
      end

      data_str = content.split(" --> ")[1]
      unless data_str
        puts "cache #{type} ##{key} data miss"
        return nil
      end

      data = JSON.parse data_str
      type_to_class(type).from_cache data
    end

    def read_all(type)
      super type

      r = self.redis
      data = []
      r.keys("#{namespace}:#{type_to_dir(type)}#*").each do |key|
        content = r.get(key)
        unless content
          puts "cache #{key} data miss"
          next
        end

        data_str = content.split(" --> ")[1]
        unless data_str
          puts "cache #{key} data miss"
          next
        end

        d = JSON.parse data_str
        data << type_to_class(type).from_cache(d)
      end

      data
    end

    def delete(type, key)
      super type, key

      res = redis.del("#{namespace}:#{type_to_dir(type)}##{key}")
      res == 1
    end

    private
    def redis
      Redis.new :host => CacheDriver.config.redis_host, :port => CacheDriver.config.redis_port
    end

    def namespace
      CacheDriver.config.redis_namespace
    end
  end
end
