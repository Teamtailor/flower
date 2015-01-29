require 'slack-rtmapi'
class Flower::Stream
  attr_reader :flower, :api_token, :client

  def initialize(flower)
    @api_token = Flower::Config.api_token
    @flower    = flower
  end

  def start
    @client = SlackRTM::Client.new(websocket_url: stream_url)

    client.on(:message) do |data|
      message = Flower::Message.new(data)
      flower.respond_to(message) if message.respond?
    end

    client.main_loop
    assert false # never ending loop
  end

  def send(data)
    client.send(data)
  end

  private

  def stream_url
    SlackRTM.get_url(token: api_token)
  end
end
