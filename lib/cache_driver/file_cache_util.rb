class FileCacheUtil < CacheUtil
  @@file_dir = CacheDriver.file_dir

  class << self
    def write(type, key, data)
      super type, data

      dir = @@file_dir.join type_to_dir(type)
      Dir.mkdir dir unless Dir.exist? dir

      file = File.new dir.join("#{key}.cache"), 'w'
      file.puts "#{Time.now} --> #{data.to_cache}"
      file.close

      key
    end

    def read(type, key)
      super type, key

      dir = @@file_dir.join type_to_dir(type)
      Dir.mkdir dir unless Dir.exist? dir

      file_path = dir.join("#{key}.cache")
      return nil unless File.exist? file_path
      file = File.new file_path, 'r'
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

      dir = @@file_dir.join type_to_dir(type)
      Dir.mkdir dir unless Dir.exist? dir
      dir_scaner = Dir.new dir

      data = []
      dir_scaner.each do |file_name|
        file = File.new dir.join(file_name), 'r'
        next unless File.file?(file) and File.extname(file) == ".cache"
        data_str = file.read.split(" --> ")[1]

        unless data_str
          puts "cache #{type} ##{file_name} data miss"
          next
        end

        d = JSON.parse data_str
        data << type_to_class(type).from_cache(d)
      end

      data
    end

    def delete(type, key)
      super type, key

      dir = @@file_dir.join type_to_dir(type)
      return true unless Dir.exist? dir

      file_path = dir.join("#{key}.cache")
      return true unless File.exist? file_path
      File.delete file_path
      true
    end
  end
end
