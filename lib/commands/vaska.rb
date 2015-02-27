# encoding: UTF-8
require_relative 'sound_command'
class Vaska < SoundCommand
  respond_to "vaska", "liv"
  listen_to /vaskar/i

  FULL = "vaska/vaska.mp3"
  FILES = Dir.glob("extras/vaska/vaska_short*.mp3").map{|f| f.gsub("extras/","")}

  def self.description
    "Jag vaskar mitt liv!"
  end

  def self.respond(message)
    play_file audio_file
  end

  def self.listen(message)
    play_file audio_file
  end

  def self.audio_file
    rand(100) > 80 ? FULL : FILES.sample
  end
end

