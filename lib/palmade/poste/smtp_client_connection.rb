# -*- encoding: binary -*-
#
# we'll just use the SmtpServer that comes with EM as a
# base implementation. But we have to re-implement it here, for the sake
# of OC-ness, so we can sleep properly.
#
# require 'em/protocols/smtpserver'
#
module Palmade::Poste
  class SmtpClientConnection < EventMachine::Connection
    include Constants

    require File.join(POSTE_LIB_DIR, 'poste/smtp_client_connection/line_text2')
    include LineText2

    require File.join(POSTE_LIB_DIR, 'poste/smtp_client_connection/processors')
    include Processors

    require File.join(POSTE_LIB_DIR, 'poste/smtp_client_connection/receivers')
    include Receivers

    @@params = {
      :chunksize => 4000,
      :max_data_size => 20000000,
      :verbose => false
    }

    def self.params=(params = { })
      @@params.merge!(params)
    end

    def initialize(*args)
      super
      @params = { }.merge(@@params)

      init_protocol_state
    end

    def params=(params)
      @params.merge!(params)
    end

    def init_protocol_state
      # set state to initial state
      @state ||= [ ]

      # init data buffer
      @databuffer = [ ]
    end

    def reset_protocol_state
      init_protocol_state

      # create new state, keep starttls, ehlo if available.
      s, @state = @state, [ ]
      @state << :starttls if s.include?(:starttls)
      @state << :ehlo if s.include?(:ehlo)

      # reset buffers, and other data
      @databuffer = [ ]

      receive_transaction
    end

    # Let's send the server greeting, in the next EM tick. This is to
    # allow EM to complete initialize the connection, before we send
    # anything in the pipe.
    #
    def post_init
      (EM.spawn { |me| me.send_server_greeting }).notify(self)
    end

    def unbind
      connection_ended
    end

    # Connection ended, perform some clean-up.
    #
    def connection_ended
      @databuffer.clear
    end

    protected

    C550RequireTLS = "550 This server requires STARTTLS\r\n".freeze
    C550RequireAuth = "550 This server requires authentication\r\n".freeze

    def check_requirements
      if (require_tls? && !state?(:starttls))
        send_data C550RequireTLS
      elsif (require_auth? && !state?(:auth))
        send_data C550RequireAuth
      else
        yield
      end
    end

    def require_auth?
      @params[:auth].to_sym == :required
    end

    def support_auth?
      @params[:auth]
    end

    def require_tls?
      @params[:starttls].to_sym == :required
    end

    def support_tls?
      @params[:starttls]
    end

    def if_verbose(&block)
      yield if @params[:verbose]
    end

    def add_state(s)
      @state << s
    end

    def remove_state(s)
      @state.delete(s)
    end

    def state?(*s)
      (s - @state).empty?
    end
  end
end
