# encoding: UTF-8
require_relative 'sound_command'
class LaggUt < SoundCommand
  respond_to "laggut", "läggut"
  listen_to /deploy/i

  FILES = Dir.glob("extras/laggut/*.mp3").map{|f| f.gsub("extras/","")}

  def self.description
    "Lägg ut!"
  end

  def self.respond(message)
    play_file FILES.sample
  end

  def self.listen(message)
    play_file FILES.sample
  end
end