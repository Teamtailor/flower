# encoding: UTF-8
require "rubygems"
require "bundler/setup"
require 'json'
require 'eventmachine'
require 'em-http'
require 'yajl'
require 'thin'

class Flower
  require_relative 'config'
  require_relative 'service'
  require_relative 'command'
  require_relative 'stats'
  require_relative '../web/app'

  COMMANDS  = {} # We are going to load available commands in here
  LISTENERS = {} # We are going to load available monitors in here

  Dir.glob("lib/commands/**/*.rb").each do |file|
    if Config.ignore_command?(file)
      puts "*** ignoring #{file}"
      next
    end
    require File.expand_path(File.join(File.dirname(__FILE__), "..", file))
  end

  attr_accessor :service, :rest, :pid

  def initialize
    require_relative "services/#{Flower::Config.service}"

    raise "no service" unless @@service.present?
    self.pid      = Process.pid
    self.service   = @@service.new(self)
  end

  def self.register_service(service)
    @@service = service
  end

  def boot!
    EM.schedule do
      trap("INT") { EM.stop }
    end

    EM.run do
      service.start
      Thin::Server.start WebApp.new(self), '0.0.0.0', 3000
    end
  end

  def respond_to(message)
    Thread.new do
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

end
