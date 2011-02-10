# -*- encoding: binary -*-
#
module Palmade::Poste
  class SmtpClientConnection
    module Processors
      include Constants

      C220SendServerGreetingReply = "220 %s\r\n".freeze

      def send_server_greeting
        send_data sprintf(C220SendServerGreetingReply, get_server_greeting)
      end

      def get_server_greeting
        SMTP_SERVER_GREETING
      end

      HeloRegex = /\AHELO\s*/i.freeze
      EhloRegex = /\AEHLO\s*/i.freeze
      QuitRegex = /\AQUIT/i.freeze
      MailFromRegex = /\AMAIL FROM:\s*/i.freeze
      RcptToRegex = /\ARCPT TO:\s*/i.freeze
      DataRegex = /\ADATA/i.freeze
      NoopRegex = /\ANOOP/i.freeze
      RsetRegex = /\ARSET/i.freeze
      VrfyRegex = /\AVRFY\s+/i.freeze
      ExpnRegex = /\AEXPN\s+/i.freeze
      HelpRegex = /\AHELP/i.freeze
      StarttlsRegex = /\ASTARTTLS/i.freeze
      AuthRegex = /\AAUTH\s+/i.freeze

      def receive_line(ln)
        if_verbose { vv ">>> %s", ln }

        if state?(:data)
          process_data_line(ln)
        elsif state?(:auth_incomplete)
          process_auth_line(ln)
        else
          case ln
          when EhloRegex
            process_ehlo $'.dup
          when HeloRegex
            process_helo $'.dup
          when MailFromRegex
            process_mail_from $'.dup
          when RcptToRegex
            process_rcpt_to $'.dup
          when DataRegex
            process_data
          when RsetRegex
            process_rset
          when VrfyRegex
            process_vrfy
          when ExpnRegex
            process_expn
          when HelpRegex
            process_help
          when NoopRegex
            process_noop
          when QuitRegex
            process_quit
          when StarttlsRegex
            process_starttls
          when AuthRegex
            process_auth $'.dup
          else
            process_unknown
          end
        end
      end

      C250NotImplementedReply = "250 Ok, but unimplemented\r\n".freeze

      # TODO - implement this properly
      def process_vrfy
        send_data C250NotImplementedReply
      end

      # TODO - implement this properly
      def process_help
        send_data C250NotImplementedReply
      end

      # TODO - implement this properly
      def process_expn
        send_data C250NotImplementedReply
      end

      def get_server_domain
        SMTP_SERVER_DOMAIN
      end

      C250GetServerDomainReply = "250 %s\r\n".freeze
      C250EhloGetServerDomainReply = "250-%s\r\n".freeze
      C250StartTLSReply = "250-STARTTLS\r\n".freeze
      C250AuthPlainReply = "250-AUTH PLAIN\r\n".freeze
      C250NoSolicitingReply = "250-NO-SOLICITING\r\n".freeze
      C250SizeReply = "250 SIZE %d\r\n".freeze

      C550RequestedActionNotTaken = "550 Requested action not taken\r\n".freeze

      def process_ehlo(domain)
        if receive_ehlo_domain(domain)
          send_data sprintf(C250EhloGetServerDomainReply, get_server_domain)

          if support_tls?
            send_data C250StartTLSReply
          end
          if support_auth?
            send_data C250AuthPlainReply
          end

          send_data C250NoSolicitingReply
          send_data sprintf(C250SizeReply, @params[:max_data_size])

          reset_protocol_state
          add_state :ehlo
        else
          send_data C550RequestedActionNotTaken
        end
      end

      def process_helo(domain)
        if receive_ehlo_domain(domain)
          send_data sprintf(C250GetServerDomainReply, get_server_domain)

          reset_protocol_state
          add_state :ehlo
        else
          send_data C550RequestedActionNotTaken
        end
      end

      C221OkReply = "221 Ok\r\n".freeze

      def process_quit
        send_data C221OkReply
        close_connection_after_writing
      end

      C250OkReply = "250 Ok\r\n".freeze

      def process_noop
        send_data C250OkReply
      end

      C550UnknownCommandReply = "550 Unknown command\r\n".freeze

      def process_unknown
        send_data C550UnknownCommandReply
      end

      C503AuthAlreadyIssuedReply = "503 auth already issued\r\n".freeze
      C504AuthMechanismNotAvailable = "504 auth mechanism not available\r\n".freeze
      C334ContinueReply = "334 \r\n".freeze

      CAuthPlainRegex = /\APLAIN\s?/i.freeze

      def process_auth(str)
        if state?(:auth)
          send_data C503AuthAlreadyIssuedReply
        elsif str =~ CAuthPlainRegex
          if $'.length == 0
            # we got a partial response, so let the client know to send the rest
            add_state :auth_incomplete
            send_data C334ContinueReply
          else
            # we got the initial response, so go ahead & process it
            process_auth_line($')
          end
        else
          send_data C504AuthMechanismNotAvailable
        end
      end

      C235AuthOkReply = "235 authentication ok\r\n".freeze
      C535InvalidAuth = "535 invalid authentication\r\n".freeze

      def process_auth_line(line)
        plain = line.unpack(Cm).first
        discard, user, psw = plain.split(Czerobyte)

        if receive_plain_auth(user, psw)
          send_data C235AuthOkReply
          add_state :auth
        else
          send_data C535InvalidAuth
        end

        remove_state :auth_incomplete
      end

      def process_rset
        reset_protocol_state
        receive_reset

        send_data C250OkReply
      end

      C503TLSAlreadyNegotiated = "503 TLS Already negotitated\r\n".freeze
      C503EhloRequiredBefore = "503 EHLO required before STARTTLS\r\n".freeze
      C220StartTLSNegotiation = "220 Start TLS negotiation\r\n".freeze

      def process_starttls
        if support_tls?
          if state?(:starttls)
            send_data C503TLSAlreadyNegotiated
          elsif !state?(:ehlo)
            send_data C503EhloRequiredBefore
          else
            send_data C220StartTLSNegotiation

            start_tls
            add_state :starttls
          end
        else
          process_unknown
        end
      end

      C503MailAlreadyGiven = "503 MAIL already given\r\n".freeze
      C550SenderUnacceptable = "550 sender is unacceptable\r\n".freeze

      def process_mail_from(sender)
        check_requirements do
          if state?(:mail_from)
            send_data C503MailAlreadyGiven
          else
            succeeded = proc {
              send_data C250OkReply
              add_state :mail_from
            }

            failed = proc {
              send_data C550SenderUnacceptable
            }

            d = receive_sender(sender)
            if d.respond_to?(:set_deferred_status)
              d.callback(&succeeded)
              d.errback(&failed)
            else
              (d ? succeeded : failed).call
            end
          end
        end
      end

      C503MailRequiredReply = "503 MAIL is required before RCPT\r\n".freeze
      C550RecipientUnacceptable = "550 recipient is unacceptable\r\n".freeze

      def process_rcpt_to(rcpt)
        check_requirements do
          unless state?(:mail_from)
            send_data C503MailRequiredReply
          else
            succeeded = proc {
              send_data C250OkReply
              add_state(:rcpt) unless state?(:rcpt)
            }

            failed = proc {
              send_data C550RecipientUnacceptable
            }

            d = receive_recipient(rcpt)
            if d.respond_to?(:set_deferred_status)
              d.callback(&succeeded)
              d.errback(&failed)
            else
              (d ? succeeded : failed).call
            end
          end
        end
      end

      C503OperationSequenceErrorReply = "503 Operation sequence error\r\n".freeze
      C354SendItReply = "354 Send it\r\n".freeze
      C550OperationFailedReply = "550 Operation failed\r\n".freeze

      def process_data
        check_requirements do
          unless state?(:mail_from, :rcpt)
            send_data C503OperationSequenceErrorReply
          else
            succeeded = proc {
              send_data C354SendItReply
              add_state :data

              @databuffer = [ ]
            }

            failed = proc {
              send_data C550OperationFailedReply
            }

            d = receive_data_command
            if d.respond_to?(:callback)
              d.callback(&succeeded)
              d.errback(&failed)
            else
              (d ? succeeded : failed).call
            end
          end
        end
      end

      C250MessageAccepted = "250 Message accepted\r\n".freeze
      C550MessageRejected = "550 Message rejected\r\n".freeze

      def process_data_line(ln)
        flush_chunk = lambda do
          receive_data_chunk(@databuffer)
          @databuffer.clear
        end

        if ln == Cdot
          flush_chunk.call if @databuffer.length > 0

          succeeded = proc {
            send_data C250MessageAccepted
          }

          failed = proc {
            send_data C550MessageRejected
          }

          d = receive_message
          if d.respond_to?(:set_deferred_status)
            d.callback(&succeeded)
            d.errback(&failed)
          else
            (d ? succeeded : failed).call
          end

          remove_state :data
        else
          # slice off leading . if any
          ln.slice!(0...1) if ln[0] == 46

          @databuffer << ln
          flush_chunk if @databuffer.length > @params[:chunksize]
        end
      end

    end
  end
end

