require "em-eventsource"
class Flower::Services::Flowdock
  class Stream
    attr_accessor :flower, :api_token, :stream

    def initialize(flower)
      self.api_token = Flower::Config.api_token
      self.flower    = flower
    end

    def start
      source = EventMachine::EventSource.new(stream_url, nil, request_headers)
      source.message do |message|
        parser << message
      end

      source.open do
        puts "** Stream open"
      end

      source.error do |error|
        puts "** error #{error}"
        puts source.ready_state
        if source.ready_state == EM::EventSource::CLOSED
          source.close
          puts "sleeping 10 seconds"
          sleep 10
          source.close
          start
        end
      end

      source.start
    end

    private

    def parser
      return @parser unless @parser.nil?
      @parser = Yajl::Parser.new(:symbolize_keys => true)
      @parser.on_parse_complete = proc do |data|
        message = Message.new(data)
        if message.respond?
          message.sender = flower.service.users[message.user_id] || flower.service.users.detect{|k,v| v[:nick] == message.sender[:nick] }.last
          flower.respond_to(message)
        end
      end
      @parser
    end

    def request_headers
      auth = Base64.encode64(api_token).strip << '='
      {:accept => 'text/event-stream', 'Authorization' => "Basic #{auth}"}
    end

    def stream_url
      "https://stream.flowdock.com/flows?active=true&filter=#{Flower::Config.flows.join(',')}"
    end
  end
end
