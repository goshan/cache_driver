class RedisCacheUtil < CacheUtil
  @@redis = Redis.new :host => CacheDriver.redis_host, :port => CacheDriver.redis_port
  @@namespace = CacheDriver.redis_namespace

  class << self
    def write(type, key, data)
      super type, data

      res = @@redis.set "#{@@namespace}:#{type_to_dir(type)}##{key}", "#{Time.now} --> #{data.to_cache}"
      res == "OK" ? key : nil
    end

    def read(type, key)
      super type, key

      content = @@redis.get("#{@@namespace}:#{type_to_dir(type)}##{key}")
      unless content
        puts "cache #{type} ##{key} data miss"
        return nil
      end

      data_str = file.read.split(" --> ")[1]
      unless data_str
        puts "cache #{type} ##{key} data miss"
        return nil
      end

      data = JSON.parse data_str
      type_to_class(type).from_cache data
    end

    def read_all(type)
      super type

      data = []
      @@redis.keys("#{@@namespace}:#{type_to_dir(type)}#*").each do |key|
        content = @@redis.get(key)
        unless content
          puts "cache #{key} data miss"
          next
        end

        data_str = file.read.split(" --> ")[1]
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

      res = @@redis.del("#{@@namespace}:#{type_to_dir(type)}##{key}")
      res == 1
    end
  end
end
