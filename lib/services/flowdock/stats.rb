# encoding: UTF-8
require 'redistat'
class Flower::Services::Flowdock
  class Stats
    include Redistat::Model

    def self.store_command_stat(message)
      store("commands/#{message.sender[:nick].downcase}", {message.command => 1}) if message.command
    rescue
      puts "REDIS ERROR"
    end

    def self.store_leaderboard_stat(message)
      report_change(message) do
        store("leaderboard", {message.sender[:nick] => 1})
      end
    rescue
      puts "REDIS ERROR"
    end

    def self.command_stats_for(nick)
      stats = find("commands/#{nick.downcase}", 1000.days.ago, 1.hour.from_now).total
      stats = stats.to_a.map {|x| [x.first.dup.force_encoding("UTF-8"), x.last] }
      stats.reject!{|v| v.blank? }
      sort_list(stats)
    end

    def self.leaderboard
      current  = sorted_leaderboard
      previous = sorted_leaderboard(1.week.ago)

      current.map do |nick, value|
        [nick, value, calculate_diff(current, previous, [nick, value])]
      end
    end

    private

    def self.report_change(message, &block)
      before = sorted_leaderboard.map(&:first)
      yield(block)
      after = sorted_leaderboard.map(&:first)
      if before != after
        passed_user = before[before.index(message.sender[:nick]) - 1]
        new_position = after.index(message.sender[:nick]) + 1
        message.say("[Leaderboard] #{message.sender[:nick]} passed #{passed_user}, and is now number #{new_position}! #{random_insult(passed_user)}") if message.flower
        play_random_sound
      end
    end

    def self.play_random_sound
      sound = ["soundfx/easy.mp3", "soundfx/rimshot.mp3", "soundfx/sadtrombone.mp3", "soundfx/yeah.mp3",
        "soundfx/applause.mp3", "soundfx/bomb.mp3", "soundfx/suprise.m4r", "soundfx/godwillsit.m4a"].sample
      Thread.new { SoundCommand.play_file(sound) }
    end

    def self.random_insult(nick)
      [
        "Get to work #{nick}.",
        "You can do better #{nick}.",
        "Why the sad face, #{nick}?",
        "You are not looking too good #{nick}.",
        "Loooser #{nick}!",
        "You are losing it, #{nick}!",
        "SAY SOMETHING #{nick}!?",
        "Are you dead #{nick}?"
      ].sample
    end

    def self.sorted_leaderboard(to_date = 1.hour.from_now)
      sort_list(find("leaderboard", 1000.days.ago, to_date).total).to_a
    end

    def self.sort_list(stats)
      stats.sort{ |a,b| b.last <=> a.last }
    end

    def self.calculate_diff(current, previous, obj)
      previous_obj = previous.find{ |key, value| obj.first == key }
      (current.index(obj) - previous.index(previous_obj)) * -1
    end
  end
end
