module CacheDriver
	class Config
		attr_accessor :store
	end

	def self.config
		@@config.store = :file
		yield @@config
	end

end
