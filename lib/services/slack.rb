module Flower::Services
  class Slack < Flower::Service
    require_relative 'slack/stream'
    require_relative 'slack/message'

    def start
      @stream = Stream.new(@flower)
      @stream.start
    end

    def send(data)
      @stream.send(data)
    end

    Flower.register_service(Slack)
  end
end
