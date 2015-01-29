# encoding: UTF-8
require "rubygems"
require "bundler/setup"
require 'json'
require 'eventmachine'
require 'em-http'
require 'yajl'
require 'thin'

class Flower
  require File.expand_path(File.join(File.dirname(__FILE__), 'config'))

  if Flower::Config.service == 'flowdock'
    require File.expand_path(File.join(File.dirname(__FILE__), 'flowdock/message'))
    require File.expand_path(File.join(File.dirname(__FILE__), 'flowdock/stream'))
    require File.expand_path(File.join(File.dirname(__FILE__), 'flowdock/rest'))
  elsif Flower::Config.service == 'slack'
    require File.expand_path(File.join(File.dirname(__FILE__), 'slack/stream'))
    require File.expand_path(File.join(File.dirname(__FILE__), 'slack/message'))
  end

  require File.expand_path(File.join(File.dirname(__FILE__), 'command'))
  require File.expand_path(File.join(File.dirname(__FILE__), 'stats'))
  require File.expand_path(File.join(File.dirname(__FILE__), '..', 'web', 'app'))

  COMMANDS = {} # We are going to load available commands in here
  LISTENERS = {} # We are going to load available monitors in here

  Dir.glob("lib/commands/**/*.rb").each do |file|
    if Config.ignore_command?(file)
      puts "*** ignoring #{file}"
      next
    end
    require File.expand_path(File.join(File.dirname(__FILE__), "..", file))
  end

  attr_accessor :stream, :rest, :users, :pid

  def initialize
    self.pid      = Process.pid
    self.stream   = Stream.new(self)
    self.rest     = Rest.new if Flower::Config.service == 'flowdock'
    self.users    = {}
  end

  def boot!
    EM.schedule do
      trap("INT") { EM.stop }
    end

    EM.run do
      get_users if Flower::Config.service == 'flowdock'
      stream.start
      Thin::Server.start WebApp.new(self), '0.0.0.0', 3000
    end
  end

  def respond_to(message)
    Thread.new do
      if Flower::Config.service == 'flowdock'
        message.sender = users[message.user_id] || users.detect{|k,v| v[:nick] == message.sender[:nick] }.last
        message.rest = rest
        Thread.exit if !message.sender # Don't break when the mnd CLI tool is posting to chat 
      end

      message.flower = self
      output = nil
      message.messages.each do |sub_message|
        sub_message.argument = output if output.present?
        if sub_message.bot_message?
          Flower::Command.delegate_command(sub_message)
          output = sub_message.output
        end
        unless message.from_self? || message.internal
          Flower::Command.trigger_listeners(sub_message)
          Flower::Command.register_stats(sub_message)
        end
      end
    end
  end

  private

  def get_users
    rest.get_users.each do |user|
      self.users[user["id"]] = {:id => user["id"], :nick => user["nick"]}
    end
  end
end
