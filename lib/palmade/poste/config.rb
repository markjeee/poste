module Palmade::Poste
  class Config
    DEFAULT_CONFIG = {
      :prefix => '/var/lib/poste',
    }

    def self.parse(config_file)
      new(YAML.load_file(config_file))
    end

    def initialize(config_hash)
      parse_config(config_hash)
    end

    def [](k)
      @config[k]
    end

    def include?(k)
      @config.include?(k)
    end

    protected

    def parse_config(config_hash)

    end
  end
end
