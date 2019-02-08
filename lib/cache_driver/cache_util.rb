class CacheUtil

  class << self
    def write(type, key, data)
      if CacheDriver.logger
        CacheDriver.logger.debug "[CACHE] save #{type} ##{key} to cache"
      else
        puts "[CACHE] save #{type} ##{key} to cache"
      end
    end

    def read(type, key)
      if CacheDriver.logger
        CacheDriver.logger.debug "[CACHE] get #{type} ##{key} from cache"
      else
        puts "[CACHE] get #{type} ##{key} from cache"
      end
    end
    
    def read_all(type)
      if CacheDriver.logger
        CacheDriver.logger.debug "[CACHE] get all #{type} from cache"
      else
        puts "[CACHE] get all #{type} from cache"
      end
    end

    def delete(type, key)
      if CacheDriver.logger
        CacheDriver.logger.debug "[CACHE] delete #{type} ##{key} from cache"
      else
        puts "[CACHE] delete #{type} ##{key} from cache"
      end
    end

    # type --> :room
    # class --> Room
    # dir --> 'rooms'
    def type_to_class(type)
      type.to_s.split('_').map(&:capitalize).join('').constantize
    end

    def class_to_type(clazz)
      cla_str = clazz.name
      cla_str.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
    end

    def type_to_dir(type)
      type.to_s + 's'
    end
  end
end
