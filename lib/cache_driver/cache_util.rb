class CacheUtil

  class << self
    def write(type, key, data)
      puts "[CACHE] save #{type} ##{key} to cache"
    end

    def read(type, key)
      puts "[CACHE] get #{type} ##{key} from cache"
    end
    
    def read_all(type)
      puts "[CACHE] get all #{type} from cache"
    end

    def delete(type, key)
      puts "[CACHE] delete #{type} ##{key} from cache"
    end

    # type --> :room
    # class --> Room
    # dir --> 'rooms'
    def type_to_class(type)
      type.to_s.split('_').map(&:capitalize).join('').constantize
    end

    def class_to_type(clazz)
      cla_str = clazz.name
      (cla_str[0].downcase + cla_str[1..-1]).to_sym
    end

    def type_to_dir(type)
      type.to_s + 's'
    end
  end
end
