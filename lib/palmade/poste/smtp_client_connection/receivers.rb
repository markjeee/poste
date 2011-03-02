# -*- encoding: binary -*-
#
module Palmade::Poste
  class SmtpClientConnection
    module Receivers
      include Constants

      # Receive and store EHLO domain setting.
      #
      def receive_ehlo_domain(domain)
        @ehlo_domain = domain.dup

        true
      end

      def receive_plain_auth(user, password)
        true
      end

      def receive_reset
        # :TODO:
      end

      # Protocol transaction reset. Happens when user needs to
      # reset transaction state to EHLO.
      #
      # Meaning, persistent conn for another message, to a different
      # recipent.
      #
      def receive_transaction
        if @ehlo_domain
          # save current ehlo_domain to the current message
          @ehlo_domain = nil
        end

        @message = SmtpMessage.new
        trx_id = @message.new_transaction!

        if_verbose { vv("New message transaction: %s", trx_id) }

        true
      end

      # Called when getting the MAIL FROM command, Check validity, and
      # fail as necessary.
      #
      # :TODO: Add checking if sender can send a message through here.
      #
      def receive_sender(sender)
        @message.set_sender(sender)
        true
      end

      # Called when getting a RCPT TO command. Check validity, and
      # fail as necessary.
      #
      # :TODO: Add checking if recipient can be routed through here.
      #
      def receive_recipient(rcpt)
        @message.add_recipient(rcpt)
        true
      end

      def receive_data_command
        true
      end

      # Called when receiving data chunk, X chunk size at a time.
      #
      def receive_data_chunk(data)
        @message << data
      end

      # Called when the entire message has been received
      # (data command has sent all stuffs in).
      #
      # This assumes, that the entire data has been stored
      # somewhere persistent (tmp file or spool directory),
      # via the multiple calls to receive_data_chunk.
      #
      def receive_message
        if_verbose { vv("Message Trx Id: %s\nSender: %s\nRecipients%s\nData size:%d",
                        @message.transaction_id,
                        @message.sender,
                        @message.recipients.inspect,
                        @message.data_size) }

        @message.store

        true
      end
    end
  end
end
