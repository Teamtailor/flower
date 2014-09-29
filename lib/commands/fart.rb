# encoding: UTF-8
require_relative 'sound_command'
class Fart < SoundCommand
  respond_to "fart", "prutt"
  listen_to "fart", "prutt"

  FILES = Dir.glob("extras/farts/*.mp3").map { |f| f.gsub("extras/", "") }

  def self.description
    "Prutt"
  end

  def self.respond(message)
    play_file FILES.sample
  end
end
