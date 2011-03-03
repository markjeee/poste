# -*- encoding: binary -*-
#
module Palmade::Poste
  class MimeMessage
    module SpoolSupport
      include Constants

      # redeclared a local constants to make encoding BINARY
      Cnewline = "\n".freeze

      module ClassMethods
        def create_from_spool(trans_id)
          spool_path = SpoolMaintainer.calculate_spool_path(trans_id)
          spool_meta_path = "#{spool_path}.meta"

          sm = MimeMessage.new
          sm.load_meta_from_spool(spool_meta_path, spool_path)
          sm
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      def in_spool?
        if defined?(@spool_meta_path) && !@spool_meta_path.nil? && File.exists?(@spool_meta_path)
          @spool_meta_path
        else
          nil
        end
      end

      def spool_path
        if defined?(@spool_path)
          @spool_path
        elsif !(smp = in_spool?).nil?
          @spool_path = smp.gsub(/\.meta\Z/, Cempty)
        else
          nil
        end
      end

      # TODO:!!!
      def read_from_spool(&block)

      end

      TRANSACTION_ID_LINE_REGEX = /\ATRANSACTION ID\: (.+)\Z/.freeze
      MAIL_FROM_LINE_REGEX = /\AMAIL FROM\: (.+)\Z/.freeze
      RCPT_TO_LINE_REGEX = /\ARCPT TO\: (.+)\Z/.freeze
      DATE_LINE_REGEX = /\ADATE\: (.+)\Z/.freeze
      SIZE_LINE_REGEX = /\ASIZE\: (.+)\Z/.freeze
      def load_meta_from_spool(spool_meta_path, spool_path)
        File.open(spool_meta_path, Crb) do |f|
          f.read.split(/\n/).each do |ln|
            case ln
            when TRANSACTION_ID_LINE_REGEX
              @transaction_id = $~[1].strip
            when DATE_LINE_REGEX
              @transaction_date = Time.parse($~[1]).utc
            when SIZE_LINE_REGEX
              @data_wrtn = $~[1].to_i
            when MAIL_FROM_LINE_REGEX
              set_sender($~[1].strip)
            when RCPT_TO_LINE_REGEX
              add_recipient($~[1].strip)
            else
              # just skip!
            end
          end
        end
      end

      TRANSACTION_ID_LINE = "TRANSACTION ID: %s\n".freeze
      MAIL_FROM_LINE = "MAIL FROM: %s\n".freeze
      RCPT_TO_LINE = "RCPT TO: %s\n".freeze
      DATE_LINE = "DATE: %s\n".freeze
      SIZE_LINE = "SIZE: %d\n".freeze
      def store_in_spool
        spool_path = SpoolMaintainer.calculate_spool_path(@transaction_id)
        spool_meta_path = "#{spool_path}.meta"
        tmp_meta_path = File.join(Palmade::Poste.config.tmp_path, "#{@transaction_id}.meta")

        begin
          File.open(spool_path, Cwb) do |f|
            if @tmp_file.nil?
              @data.each { |d| f.write(d); f.write(Cnewline) }
            else
              @tmp_file.rewind
              while(!@tmp_file.eof)
                f.write(@tmp_file.read(C16k))
              end
            end
          end

          File.open(tmp_meta_path, Cwb) do |f|
            f.write(TRANSACTION_ID_LINE % @transaction_id)
            f.write(DATE_LINE % @transaction_date)
            f.write(SIZE_LINE % data_size)
            f.write(MAIL_FROM_LINE % @sender)

            @recipients.each do |rcpt|
              f.write(RCPT_TO_LINE % rcpt)
            end
          end
          File.rename(tmp_meta_path, spool_meta_path)

          @spool_path = spool_path
          @spool_meta_path = spool_meta_path

          # let's close tmp file, and clear data buffer.
          close_tmp_file unless @tmp_file.nil?
          @data.clear
        rescue Exception => e
          File.unlink(spool_path) if File.exists?(spool_path)
          File.unlink(tmp_meta_path) if File.exists?(tmp_meta_path)
          File.unlink(spool_meta_path) if File.exists?(spool_meta_path)

          raise e
        end

        @spool_meta_path
      end
    end
  end
end
