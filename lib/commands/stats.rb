# encoding: utf-8
class Stats < Flower::Command
  respond_to "stats"
  CHARTBEAT_URL = "http://api.chartbeat.com"

  def self.respond(command, message, sender, flower)
    message_array = message.split(" ")
    case message_array.first
    when "online"
      flower.paste ["Online right now: #{online_right_now}"]
    when "commands"
      nick = message_array[1] || sender[:nick]
      flower.paste ["Top 10 for #{nick}"] << command_stats_for(nick)
    else
      flower.say("Online right now: #{online_right_now}")
    end
  end

  def self.description
    "Online right now"
  end

  private

  def self.command_stats_for(nick)
    stats = Flower::Stats.command_stats_for(nick)
    response = stats.sort{|a,b| b.last <=> a.last}.map {|type, value| "#{type}: #{value}"}.take(10)
    response << "totalt: #{stats.values.inject(:+) || 0}"
  end

  def self.online_right_now
    require 'open-uri'
    doc = open "#{CHARTBEAT_URL}/quickstats?host=#{Flower::Config.chartbeat['domain']}&apikey=#{Flower::Config.chartbeat['key']}"
    json = JSON.parse doc.read
    json["people"]
  end
end
