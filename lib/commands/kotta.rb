# encoding: UTF-8
require_relative 'sound_command'
class Kotta < SoundCommand
  respond_to "kötta"
  listen_to /kötta/i

  FILES = Dir.glob("extras/kotta/*.mp3").map{|f| f.gsub("extras/","")}

  def self.description
    "Men kan du kötta?!"
  end

  def self.respond(message)
    play_file FILES.sample
  end

  def self.listen(message)
    play_file FILES.sample
  end
end

