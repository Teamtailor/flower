require 'giphy'

class Gif < Flower::Command
  respond_to "gif"

  def self.description
    "Search for a gif or Post a random gif"
  end

  def self.respond(message)
    if query = message.argument
      message.say(Giphy.random(query).image_url.to_s)
    else
      message.say(Giphy.random.image_url.to_s)
    end
  end
end
