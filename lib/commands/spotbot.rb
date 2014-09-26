# encoding: UTF-8
class Spotbot < Flower::Command
  respond_to "play", "pause", "track", "stam", "search", "queue", "seek"

  def self.respond(message)
    case message.command
    when "pause"
      pause
      message.say("Stopped playing")
    when "stam"
      pause
      message.say("Stam in da house")
    when "track"
      message.paste current_track
    when "queue"
      case message.argument
      when nil
        message.paste queue.map{|track| track_title_from_json(track)}
      when 'clear'
        connection.delete('queue')
        message.say "Queue is empty."
      else
        track = queue_track(message.argument)
        message.say "Added to queue: #{track_title_from_json(track)}"
      end
    when "play"
      case message.argument
      when nil
        play
      when "next"
        play_next
      else
        if message.argument.match(/\.*\:playlist\:|\.*\:album\:/)
          playlist = connection.post('playlist', uri: message.argument).body
          if playlist
            message.say("Playing from playlist #{playlist["playlist"]}")
          else
            message.say("Playlist not found – is it maybe private?")
          end
        else
          play_track message.argument
        end
      end
      message.say track_title_from_json(connection.get('player/track').body)
    end
  end

  def self.description
    "Spotify: \\\"play\\\", \\\"pause\\\", \\\"track\\\", \\\"queue\\\""
  end

  def self.play
    connection.put('player/start')
  end

  def self.pause
    connection.put('player/stop')
  end

  def self.play_track(uri)
    connection.post('player/track', uri: uri)
  end

  def self.play_next
    connection.put('player/next')
  end

  def self.queue_track(uri)
    connection.post('queue/tracks', uri: uri).body
  end

  def self.current_track
    track_title_from_json connection.get('player/track').body
  end

  def self.queue
    connection.get('queue/tracks').body.map{|t| track_title_from_json t}
  end

  private

  def self.connection
    @connection ||= Faraday.new(:url => Flower::Config.spotbot_url) do |conn|
      conn.request :url_encoded
      conn.response :json, :content_type => /\bjson$/
      conn.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def self.track_title_from_json(json)
    "#{json["artists"].join(", ")} – #{json["title"]}"
  end
end
