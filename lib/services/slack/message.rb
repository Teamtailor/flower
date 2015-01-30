class Flower::Services::Slack::Message
  attr_reader :data, :output
  attr_accessor :sender, :flower, :internal

  def initialize(data)
    @data = data
  end

  def channel
    @channel ||= data["channel"]
  end

  def content
    @content ||= data["content"]
  end

  def command
    if msg = bot_message
      msg[1].split(" ").first
    end
  end

  def argument
    @argument ||= message.split(" ", 2)[1]
  end

  def argument=(argument)
    @argument = argument
  end

  def event
    @event ||= data["type"]
  end

  def respond?
    event == "message"
  end

  def from_self?
    # sender[:nick] == Flower::Config.bot_nick
    false
  end

  def nick
    # sender[:nick]
    "unknown"
  end

  def user_id
    @user ||= data["user"]
  end

  def bot_message
    message.respond_to?(:match) && message.match(/^(?:!)[\s|,|:]*(.*)/i)
  end

  def bot_message?
    !!bot_message
  end

  def message
    @message ||= data["text"]
  end

  def message=(message)
    @message = message
  end

  def messages
    messages = message.split("|")
    if messages.size > 1
      messages.map do |sub_message|
        new_message = self.dup
        new_message.message = sub_message
        new_message
      end
    else
      [self]
    end
  end

  def say(reply, options = {})
    flower.service.send(type: 'message', channel: channel, text: reply)
  end

  def paste(reply, options = {})
    reply = reply.join("\n") if reply.respond_to?(:join)
    reply = "```#{reply}```"
    flower.service.send(type: 'message', channel: channel, text: reply)
  end
end
