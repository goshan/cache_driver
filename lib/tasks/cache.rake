namespace :cache do
	desc "inspect cache content"
	task :inspect => :environment do
		show_models = /show models/i
		desc_model = /desc (\S+)/i
		select = /select from (\S+)( where id\s?=\s?(\d+))?/i
		insert = /insert into (\S+) values ({.*})/i
		delete = /delete from (\S+) where id\s?=\s?(\d+)/i


		# forbidden stdout info in CacheRecord
		cache_out = StringIO.new
		$stdout = cache_out

		while true
			$stdout.truncate 0
			STDOUT.print "CacheDriver > "
			cmd = STDIN.gets
			cmd.chomp!

			if cmd == ""
				next
			elsif cmd == "exit"
				break
			end

			if cmd =~ show_models
				dir = Dir.new File.expand_path("../../../tmp/cache", __FILE__)
				STDOUT.puts "-------------------------------"
				STDOUT.puts "models: "
				STDOUT.puts "-------------------------------"
				dir.each do |file|
					if file =~ /.+s/i
						STDOUT.puts file[0..-2]
					end
				end
				STDOUT.puts "-------------------------------"
				STDOUT.puts ""
			elsif cmd =~ desc_model
				res = cmd.match desc_model
				clazz = CacheUtil.type_to_class res[1].downcase.to_sym
				ins = clazz.find_all.first
				unless ins
					STDOUT.puts "error: can not find model #{res[1]}"
					next
				end
				STDOUT.puts "-------------------------------"
				STDOUT.puts "attributes: "
				STDOUT.puts "-------------------------------"
				ins.instance_variables.each do |var|
					STDOUT.puts var
				end
				STDOUT.puts "-------------------------------"
				STDOUT.puts ""
			elsif cmd =~ select
				res = cmd.match select
				clazz = CacheUtil.type_to_class res[1].downcase.to_sym
				STDOUT.puts "-------------------------------"
				STDOUT.puts "#{clazz} records: "
				STDOUT.puts "-------------------------------"
				if res[2]        # where id = x
					ins = clazz.find_by_id res[3].to_i
					if ins
						STDOUT.print "{"
						ins.instance_variables.each_with_index do |var, index|
							STDOUT.print "#{var} => #{ins.instance_variable_get var}#{index == ins.instance_variables.count ? "" : ", "}"
						end
						STDOUT.print "}\n"
						STDOUT.puts "-------------------------------"
						STDOUT.puts "1 records"
					else
						STDOUT.puts "0 records"
					end
				else    # no where
					all_ins = clazz.find_all
					all_ins.each do |ins|
						STDOUT.print "{"
						ins.instance_variables.each_with_index do |var, index|
							STDOUT.print "#{var} => #{ins.instance_variable_get var}#{index == ins.instance_variables.count-1 ? "" : ", "}"
						end
						STDOUT.print "}\n"
					end
					STDOUT.puts "-------------------------------"
					STDOUT.puts "#{all_ins.count} records"
				end
				STDOUT.puts ""
			elsif cmd =~ insert
				res = cmd.match insert
				clazz = CacheUtil.type_to_class res[1].downcase.to_sym
				STDOUT.puts "-------------------------------"
				STDOUT.puts "insert #{clazz} record: "
				STDOUT.puts "-------------------------------"
				ins = clazz.new
				res[2].split(',').each do |assign|
					ele = assign.match /(\S+)\s?=\s?(\S+)/i
					ins.send "#{ele[1]}=", ele[2]
				end
				ins.save!
				STDOUT.puts "inserted record"
				STDOUT.puts "-------------------------------"
				STDOUT.puts ""
			elsif cmd =~ delete
				res = cmd.match delete
				clazz = CacheUtil.type_to_class res[1].downcase.to_sym
				STDOUT.puts "-------------------------------"
				STDOUT.puts "delete #{clazz} record: "
				STDOUT.puts "-------------------------------"
				ins = clazz.find_by_id res[2].to_i
				ins.destroy
				STDOUT.puts "deleted record"
				STDOUT.puts "-------------------------------"
				STDOUT.puts ""
			else
				STDOUT.puts "error: unknow command '#{cmd}'"
			end
		end


	end
end
