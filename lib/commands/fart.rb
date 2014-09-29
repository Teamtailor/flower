# encoding: UTF-8
require_relative 'sound_command'
class Fart < SoundCommand
  respond_to "fart", "prutt", "fis"
  listen_to "fart", "prutt", "fis"

  FILES = Dir.glob("extras/farts/*.mp3").map { |f| f.gsub("extras/", "") }

  def self.description
    "Prutt"
  end

  def self.respond(message)
    fart
  end

  def self.listen(message)
    fart
  end

  private

  def self.fart
    play_file FILES.sample
  end
end
