module CacheDriver
	class Config
		attr_accessor :store
	end

	def self.config
		@@config
	end

	def self.setup
		@@config.store = :file
		yield @@config
	end

end
