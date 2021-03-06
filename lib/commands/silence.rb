# encoding: UTF-8
require_relative 'sound_command'
class Silence < SoundCommand
  respond_to "silence"

  def self.description
    "Enjoy the silence  (for 5 mins)"
  end

  def self.respond(message)
    unless silenced?
      self.silenced_at = Time.now + 300 # 5 minutes from now
      message.say("Enjoy the silence  (for 5 mins)")
    else
      say_silenced(message)
    end
  end

  def self.say_silenced(message)
    message.say "Already silenced for another #{seconds_left} seconds."
  end

  def self.seconds_left
    (silenced_at - Time.now).to_i
  end
end
