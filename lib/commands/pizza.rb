require 'typhoeus'
class Pizza < Flower::Command
  respond_to "pizza"

  def self.description
    "Pizza all the time - GIF"
  end

  def self.respond(message)
    msg.say "http://animatedpizzagifs.com/#{images.sample}"
  end

  def self.images
    @@images ||= begin
      response = Typhoeus::Request.get("https://api.github.com/repos/clintecker/animatedpizzagifs/contents/images?ref=gh-pages", :headers => { 'User-Agent' => 'Flower, the flowdock bot' })
      JSON.parse(response.body).map do |image|
        image["path"]
      end
    end
  end
end
