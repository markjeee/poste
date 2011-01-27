module Palmade::Poste
  module Constants
    PROGRAM_NAME = 'poste'.freeze

    SMTP_SERVER_GREETING = "#{PROGRAM_NAME} SMTP Server".freeze
    SMTP_SERVER_DOMAIN = "Ok #{PROGRAM_NAME} SMTP Server".freeze

    DEFAULT_CONFIG_FILE = '/etc/poste/poste.yml'.freeze

    Cempty = "".freeze
    Cm = 'm'.freeze
    Cdot = '.'.freeze
    Czerobyte = "\000".freeze
    Cnewline = "\n".freeze
  end
end
