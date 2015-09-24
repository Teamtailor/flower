class Volume < Flower::Command
  respond_to "volume", "vol"

  def self.respond(message)
    return if message.user_id == "U03GLV68H"
    if message.argument
      if validate_message(message.argument)
        adjust_volume(message.argument)
      else
        message.say("Please use only + or -", :mention => message.user_id)
      end
    else
      say_current_vol(message)
    end
  end

  def self.description
    "+'s or -'s. The more the merrier."
  end

  def self.current_volume
    `osascript -e 'get output volume of (get volume settings)'`.strip.to_i
  end

  def self.set_volume(volume)
    system("osascript -e 'set volume output volume #{volume}'")
  end

  private

  def self.validate_message(up_or_down)
    up_or_down =~ /^[\+]+$/ or up_or_down =~ /^[\-]+$/
  end

  def self.adjust_volume(up_or_down)
    amount = up_or_down.length * 5
    new_volume = if up_or_down[0] == "+"
      current_volume + amount
    else
      current_volume - amount
    end
    new_volume = 0 if new_volume < 0
    new_volume = 100 if new_volume > 100
    set_volume(new_volume)
  end

  def self.say_current_vol(flower)
    meter = "="*(current_volume/3)
    flower.paste("[#{meter.ljust(33)}]")
  end
end
