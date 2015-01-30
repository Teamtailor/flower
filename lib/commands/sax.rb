# encoding: UTF-8
require_relative 'sound_command'
class Sax < SoundCommand
  respond_to "sax"

  def self.description
    "Epic sax"
  end

  def self.respond(message)
    if rand(100) == 1
      play_file "sax/retrosaxguy.m4a"
    else
      play_file "sax/epicsaxguy.m4a"
    end
  end
end
