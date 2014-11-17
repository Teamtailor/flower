# encoding: UTF-8
require_relative 'sound_command'
class SoundFx < SoundCommand
  respond_to "easy", "rimshot", "sad", "yeah", "applause", "bomb", "kötta",
    "suprise", "snore", "godwillsit", "sting", "pengar", "rik", "fel",
    "khan", "khan?", "tarelugnt", "tadetlugnt", "keke", "judas", "priest",
    "fascinating", "party", "tihi", "merikuh", "team", "gott", "bigbang", "itsatrap"

  def self.description
    "Awesome audio fx!"
  end

  def self.respond(message)
    case message.command
    when "easy"
      play_file "soundfx/easy.mp3"
    when "rimshot"
      play_file "soundfx/rimshot.mp3"
    when "sad"
      play_file "soundfx/sadtrombone.mp3"
    when "yeah"
      play_file "soundfx/yeah.mp3"
    when "applause"
      play_file "soundfx/applause.mp3"
    when "bomb"
      play_file "soundfx/bomb.mp3"
    when "suprise"
      play_file "soundfx/suprise.m4r"
    when "snore"
      play_file "soundfx/snore.wav"
    when "godwillsit"
      play_file "soundfx/godwillsit.m4a"
    when "party"
      play_file "soundfx/notgettingin.mp3"
    when "pengar"
      play_file "soundfx/pengar.mp3"
    when "rik"
      play_file "soundfx/rik.mp3"
    when "tihi"
      play_file "soundfx/tihi.mp3"
    when "fel"
      play_file "soundfx/fel.mp3"
    when "sting"
      play_file "soundfx/sting.wav"
    when "khan"
      play_file "soundfx/khan.wav"
    when "khan?"
      play_file "soundfx/khan.wav"
    when "kötta"
      play_file "soundfx/kotta.mp3"
    when "tarelugnt"
      play_file "soundfx/tadetlugnt.wav"
    when "tadetlugnt"
      play_file "soundfx/tadetlugnt.wav"
    when "keke"
      play_file "soundfx/#{%w(pengar fel rik).sample}.mp3"
    when /judas|priest/
      play_file "judas/judas#{rand(25)+1}.mp3"
    when "fascinating"
      play_file "soundfx/fascinating.mp3"
    when "merikuh"
      play_file "soundfx/merikuh.mp3"
     when "team"
       play_file "soundfx/team.mp3"
     when "gott"
       play_file "soundfx/gott.wav"
     when "bigbang"
       play_file "soundfx/Picture-a-Hot-Dog-Bun.mp3"
     when "itsatrap"
       play_file "soundfx/itsatrap.mp3"
    end
  end
end
