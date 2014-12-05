require 'giphy'

class Gif < Flower::Command
  respond_to "gif"

  def self.description
    "Search for a gif or Post a random gif"
  end

  def self.respond(message)
    if query = message.argument
      message.say(Giphy.random(query))
    else
      message.say(Giphy.random)
    end
  end
end
