module Flower::Services
  class Flowdock < Flower::Service
    attr_reader :users
    require_relative 'flowdock/stream'
    require_relative 'flowdock/message'
    require_relative 'flowdock/rest'

    def start
      @users = {}
      get_users
      stream = Stream.new(@flower)
      stream.start
    end

    def send(reply, tags, message)
      rest.post_message(reply, tags, message)
    end

    def rest
      @rest ||= Rest.new
    end

    private

    def get_users
      rest.get_users.each do |user|
        @users[user["id"]] = {:id => user["id"], :nick => user["nick"]}
      end
    end

    Flower.register_service(Flowdock)
  end
end
