class CacheRecord
	def self.find_all
		if CacheDriver.store_file?
			FileCacheUtil.read_all CacheUtil.class_to_type(self)
		end
	end

	def self.find_by_id(id)
		if CacheDriver.store_file?
			FileCacheUtil.read CacheUtil.class_to_type(self), id
		end
	end

	def save!
		if CacheDriver.store_file?
			FileCacheUtil.write CacheUtil.class_to_type(self.class), self
		end
	end

	def destroy
		if CacheDriver.store_file?
			FileCacheUtil.delete CacheUtil.class_to_type(self.class), self.id
		end
	end

	def to_cache
		self.to_json
	end

	def self.from_cache(str)
		json = JSON.parse str
		ins = self.new
		attr_key = ins.instance_variables.map{|var| var.to_s[1..-1]}]}
		attr_key.each do |attr|
			ins.send "#{attr_key}=", json[attr]
		end
		ins
	end
end
