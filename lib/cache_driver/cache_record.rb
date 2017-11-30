class CacheRecord
  @@cache_util = CacheDriver.store_file? ? FileCacheUtil : CacheDriver.store_redis? ? RedisCacheUtil : nil

  def self.find_all
    @@cache_util.read_all CacheUtil.class_to_type(self)
  end

  def self.find_by_key(key)
    @@cache_util.read CacheUtil.class_to_type(self), id
  end

  def save!
    @@cache_util.write CacheUtil.class_to_type(self.class), self
  end

  def destroy
    @@cache_util.delete CacheUtil.class_to_type(self.class), self.id
  end

  def to_cache
    self.to_json
  end

  def self.from_cache(obj)
    ins = self.new
    obj.each do |key, value|
      ins.send "#{key}=", value
    end
    ins
  end
end
