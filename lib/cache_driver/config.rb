module CacheDriver
	class Config
		attr_accessor :store
	end

	@@config = Config.new

	def self.configed?
		@@config.store
	end

	def self.store_file?
		@@config.store == :file
	end

	def self.store_redis?
		false
	end

	def self.setup
		yield @@config
	end

end
