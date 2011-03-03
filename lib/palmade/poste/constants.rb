module Palmade::Poste
  module Constants
    PROGRAM_NAME = 'poste'.freeze
    DEFAULT_CONFIG_FILE = '/etc/poste/poste.yml'.freeze

    SMTP_SERVER_GREETING = "#{PROGRAM_NAME} SMTP Server".freeze
    SMTP_SERVER_DOMAIN = "Ok #{PROGRAM_NAME} SMTP Server".freeze

    Cempty = "".freeze
    Cm = 'm'.freeze
    Cw = 'w'.freeze
    Cwb = 'wb'.freeze
    Crb = 'rb'.freeze
    Cdot = '.'.freeze
    Czerobyte = "\000".freeze
    Cnewline = "\n".freeze

    C16k = (16 * 1024).freeze
  end
end
