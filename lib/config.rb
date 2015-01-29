require 'yaml'

class Flower::Config
  CONFIG = YAML.load File.read(ENV.fetch("CONFIG") {"config.yml"})

  def self.ignore_command?(file_path)
    return unless CONFIG["ignore_commands"]
    CONFIG["ignore_commands"].any? do |pattern|
      file_path.include?(pattern)
    end
  end

  def self.method_missing(sym, *args, &block)
    CONFIG[sym.to_s]
  end
end
