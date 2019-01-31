class CacheRecord
  def self.key_attr
    nil
  end

  def self.find_all
    CacheRecord.cache_util.read_all CacheUtil.class_to_type(self)
  end

  def self.find_by_key(key)
    CacheRecord.cache_util.read CacheUtil.class_to_type(self), key
  end

  def self.find_current
    if self.key_attr
      raise "#{self} is not a unique class, use method find_by_key instead"
    else
      self.find_by_key "current"
    end
  end

  def self.clear
    self.find_all.each(&:destroy)
  end

  def save
    raise "attr key :#{self.class.key_attr} is missing" if self.key_attr_missing?

    CacheRecord.cache_util.write CacheUtil.class_to_type(self.class), self.class.key_attr ? self.send(self.class.key_attr) : "current", self
  end

  def destroy
    raise "attr key :#{self.class.key_attr} is missing" if self.key_attr_missing?

    CacheRecord.cache_util.delete CacheUtil.class_to_type(self.class), self.class.key_attr ? self.send(self.class.key_attr) : "current"
  end

  def to_cache
    res = {}
    self.instance_variables.each do |var|
      var_name = var.to_s.delete('@')
      res[var_name.to_sym] = self.instance_variable_get("@#{var_name}")
    end
    res
  end

  def self.from_cache(obj)
    ins = self.allocate
    obj.each do |key, value|
      ins.instance_variable_set "@#{key}", value
    end
    ins
  end

  private
  def self.cache_util
    CacheDriver.store_file? ? FileCacheUtil : CacheDriver.store_redis? ? RedisCacheUtil : nil
  end

  protected
  def key_attr_missing?
    self.class.key_attr && self.instance_variable_get("@#{self.class.key_attr}").nil?
  end
end
