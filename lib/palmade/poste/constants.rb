module Palmade::Poste
  module Constants
    PROGRAM_NAME = 'poste'.freeze
    DEFAULT_CONFIG_FILE = '/etc/poste/poste.yml'.freeze

    SMTP_SERVER_GREETING = "#{PROGRAM_NAME} SMTP Server".freeze
    SMTP_SERVER_DOMAIN = "Ok #{PROGRAM_NAME} SMTP Server".freeze

    Cempty = "".freeze
    Cm = 'm'.freeze
    Cdot = '.'.freeze
    Czerobyte = "\000".freeze
    Cnewline = "\n".freeze

    SMTP_MESSAGE_TRX_ID_FORMAT = "%04x%04x%04x%06x%06x%s".freeze
  end
end
