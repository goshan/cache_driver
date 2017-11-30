class CacheRecord

  def self.find_all
    CacheRecord.cache_util.read_all CacheUtil.class_to_type(self)
  end

  def self.find_by_key(key)
    CacheRecord.cache_util.read CacheUtil.class_to_type(self), key
  end

  def save!
    CacheRecord.cache_util.write CacheUtil.class_to_type(self.class), self.send(self.class.key_attr), self
  end

  def destroy
    CacheRecord.cache_util.delete CacheUtil.class_to_type(self.class), self.send(self.class.key_attr)
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

  private
  def self.cache_util
    CacheDriver.store_file? ? FileCacheUtil : CacheDriver.store_redis? ? RedisCacheUtil : nil
  end
end
