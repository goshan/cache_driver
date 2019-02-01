class CacheDriverClient
  def initialize
    if CacheDriver.config.store == :file
      @cli = CacheDriver.config.file_dir
    elsif CacheDriver.config.store == :redis
      @cli = Redis.new :host => CacheDriver.config.redis_host, :port => CacheDriver.config.redis_port
    end
  end

  def show_models
    models = []
    if @cli.class == Pathname
      @cli.each_child do |file|
        filename = file.basename.to_s
        if filename =~ /.+s/i
          models << filename[0..-2]
        end
      end
    elsif @cli.class == Redis
      models = @cli.keys.map do |key|
        key.gsub("#{CacheDriver.config.redis_namespace}:", '').gsub(/#.+/, '')
      end.uniq
    end
    models.sort
  end

  def show_keys(model)
    model = "#{model}s"
    keys = []
    if @cli.class == Pathname
      @cli.join(model).each_child do |file|
        filename = file.basename.to_s
        if filename =~ /\.cache/i
          keys << filename.gsub(/\.cache/, '')
        end
      end
    elsif @cli.class == Redis
      keys = @cli.keys("#{CacheDriver.config.redis_namespace}:#{model}*").map do |key|
        key.gsub("#{CacheDriver.config.redis_namespace}:", '').gsub(/.+#/, '')
      end
    end
    keys.sort
  end

  def find(model, key)
    model = "#{model}s"
    if @cli.class == Pathname
      file = @cli.join(model, "#{key}.cache")
      return nil unless file.exist? && file.file?
      json = File.read file
    elsif @cli.class == Redis
      json = @cli.get("#{CacheDriver.config.redis_namespace}:#{model}##{key}")
    end

    return nil unless json

    res = json.split ' --> '
    res[1] = JSON.parse res[1]
    res
  end

  def save(model, key, assignments)
    STDOUT.puts assignments.inspect
  end

  def delete(model, key)
    model = "#{model}s"
    if @cli.class == Pathname
      file = @cli.join(model, "#{key}.cache")
      if file.exist? && file.file?
        file.delete
        res = 1
      else
        res = 0
      end
    elsif @cli.class == Redis
      res = @cli.del("#{CacheDriver.config.redis_namespace}:#{model}##{key}")
    end
    res == 1
  end

  def clear(model)
    model = "#{model}s"
    if @cli.class == Pathname
      res = []
      @cli.join(model).each_child do |file|
        filename = file.basename.to_s
        if filename =~ /\.cache/i
          file.delete
          res << [filename.gsub(/\.cache/, ''), 1]
        else
          res << [filename, 0]
        end
      end
    elsif @cli.class == Redis
      res = @cli.keys("#{CacheDriver.config.redis_namespace}:#{model}*").map do |key|
        r = @cli.del key
        [key.gsub("#{CacheDriver.config.redis_namespace}:", '').gsub(/.+#/, ''), r]
      end
    end
    Hash[res]
  end
end



namespace :cache do
	desc "inspect cache content with CacheDriver"
	task :inspect => :environment do
    quit = /exit/
    help = /\?/
		show_models = /show models/i
		show_keys = /show keys (\S+)/i
		find = /find (\S+) in (\S+)/i
		save = /save (\S+) to (\S+) with (.*)/i
		delete = /delete (\S+) in (\S+)/i
    clear = /clear (\S+)/i

    prompt = TTY::Prompt.new interrupt: :exit
    client = CacheDriverClient.new

    unless CacheDriver.configed?
      prompt.erro "CacheDriver configure not found, setup config in environments first"
      exit 1
    end

		while true
      begin
        cmd = prompt.ask "CacheDriver >", active_color: :cyan do |q|
          q.modify :down, :trim
          q.convert -> (input) do
            if input =~ quit
              {action: :exit}
            elsif input =~ help
              {action: :help}
            elsif input =~ show_models
              {action: :show_models}
            elsif input =~ show_keys
              res = input.match show_keys
              {action: :show_keys, model: res[1].downcase}
            elsif input =~ find
              res = input.match find
              {action: :find, model: res[1].downcase, key: res[2]}
            elsif input =~ save
              res = input.match save
              assignments = {}
              res[2].split(',').each do |assign|
                ele = assign.match /(\S+)\s?=\s?(\S+)/i
                assignments[ele[1]] = ele[2] if ele
              end
              {action: :save, model: res[1].downcase, key: res[2], assignments: assignments}
            elsif input =~ delete
              res = input.match delete
              {action: :delete, model: res[1].downcase, key: res[2]}
            elsif input =~ clear
              res = input.match clear
              {action: :clear, model: res[1].downcase}
            else
              {action: :unknown}
            end
          end
        end

        next if cmd.nil?

        case cmd[:action]
        when :exit
          prompt.say "Bye!".green.bold
          exit
        when :help
          prompt.say "Commands:                                     \r".on_green.bold
          prompt.say "'?'                                            | show all commands and descriptions\n"
          prompt.say "show models                                    | list all models\n"
          prompt.say "show keys <model>                              | list all keys of model in cache\n"
          prompt.say "find <model> in <key>                          | fetch data of model\n"
          prompt.say "save <model> to <key> withs <attr1>=<val1>,... | update data of model, create one if not existed\n"
          prompt.say "delete <model> in <key>                        | delete data of model\n"
          prompt.say "clear <model>                                  | delete data of model\n"
        when :show_models
          prompt.say "Models:                                       \r".on_green.bold
          client.show_models.each do |model|
            prompt.say model
          end
        when :show_keys
          prompt.say "Keys of #{cmd[:model]}:                                  \r".on_green.bold
          client.show_keys(cmd[:model]).each do |key|
            prompt.say key
          end
        when :find
          prompt.say "Cache of #{cmd[:model]}##{cmd[:key]}:                               \r".on_green.bold
          res = client.find cmd[:model], cmd[:key]
          if res && res.count >= 2
            prompt.say "Last Modified Time: #{res[0]}".yellow
            res[1].each do |key, val|
              prompt.say "@#{key} => #{val.inspect}"
            end
          else
            prompt.error "no records found"
          end
        when :save
          client.save cmd[:model], cmd[:key], cmd[:assignments]
        when :delete
          prompt.say "Delete #{cmd[:model]}##{cmd[:key]}:                               \r".on_green.bold
          res = client.delete cmd[:model], cmd[:key]
          if res
            prompt.ok "delete #{cmd[:model]}##{cmd[:key]} successed"
          else
            prompt.error "delete #{cmd[:model]}##{cmd[:key]} failed"
          end
        when :clear
          prompt.say "Clear #{cmd[:model]}:                               \r".on_green.bold
          res = client.clear cmd[:model]
          prompt.say "#{cmd[:model]}#(#{res.map { |k, v| v == 1 ? k : k.red}.join(',')}) was deleted"
        else
          prompt.error "error: unknow command"
          next
        end
        prompt.say "----------------------------------------------\r"
        prompt.say "\r"
      rescue => e
        prompt.error "error: #{e.message}"
      end
    end


	end
end
