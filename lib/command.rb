class Flower::Command
  def self.respond_to(*commands)
    commands.each do |command|
      if Flower::COMMANDS[command]
        warn "Command already defined: #{command}"
      else
        Flower::COMMANDS[command] = self if allowed_command?(command)
      end
    end
  end

  def self.allowed_command?(command)
    return true if Flower::Config.parental_control.nil?
    Flower::Config.parental_control.include?(command)
  end

  def self.listen_to(*regexps)
    regexps.each do |regexp|
      if Flower::LISTENERS[regexp]
        warn "Listener already defined: #{regexp}"
      else
        Flower::LISTENERS[regexp] = self
      end
    end
  end

  def self.delegate_command(message)
    return false if Flower::COMMANDS[message.command].nil?
    begin
      Flower::COMMANDS[message.command].respond(message)
    rescue => error
      puts error
      puts error.backtrace
      post_error(error, message.inspect)
    end
  end

  def self.register_stats(message)
    Flower::Services::Flowdock::Stats.store_leaderboard_stat(message)
    Flower::Services::Flowdock::Stats.store_command_stat(message)
  end

  def self.trigger_listeners(message)
    return false if Flower::LISTENERS.empty?
    return false if message.bot_message?
    Flower::LISTENERS.map do |regexp, command|
      begin
        command.listen(message) if message.message.match(regexp)
      rescue => error
        puts error
        puts error.backtrace
        post_error(error, message)
      end
    end
  end

  private
  def self.post_error(error, message)
    # message.say(":( `#{message.command}` raised error: #{error}")
  end
end
