require 'tempfile'
require 'digest/md5'
require 'tempfile'

module Palmade::Poste
  class SmtpMessage
    include Constants

    # maximum data in memory is 640kb
    MAX_DATA_IN_MEMORY = 640 * 1024
    # MAX_DATA_IN_MEMORY = 16

    SMTP_MESSAGE_TEMP_FILE_PREFIX = "#{PROGRAM_NAME}.smtp_message".freeze

    attr_reader :transaction_id
    attr_reader :sender
    attr_reader :recipients
    attr_reader :data

    autoload :SpoolSupport, File.join(POSTE_LIB_DIR, 'poste/smtp_message/spool_support')
    include SpoolSupport

    autoload :MongoSupport, File.join(POSTE_LIB_DIR, 'poste/smtp_message/mongo_support')
    include MongoSupport

    def self.generate_trx_id
      srand(Time.now.usec)

      Digest::MD5.hexdigest(SMTP_MESSAGE_TRX_ID_FORMAT %
                            [
                             rand(0x0010000),
                             rand(0x0010000),
                             rand(0x0010000),
                             rand(0x1000000),
                             rand(0x1000000),
                             String(Time::now.usec)
                            ]).freeze
    end

    def initialize
      @transaction_id = nil
      @transaction_date = nil

      @sender = nil
      @recipients = [ ]

      @data = [ ]
      @data_wrtn = 0
      @tmp_file = nil
    end

    # Initialize object as a new e-mail transaction. Generates a new
    # transaction id, and sets the timestamp in UTC format.
    #
    def new_transaction!
      @transaction_id = self.class.generate_trx_id
      @transaction_date = Time.now.utc
      @transaction_id
    end

    def set_sender(sender)
      @sender = sender
    end

    def add_recipient(rcpt)
      @recipients << rcpt unless recipients.include?(rcpt)
    end

    def <<(chunk)
      if chunk.respond_to?(:each)
        chunk.each { |d| write_data(d) }
      else
        write_data(chunk)
      end
    end

    # invokes, initial storage in var spool
    # Strategy:
    #   store in spool directory, and then schedule it for
    #   storing in mongodb.
    #
    def store

    end

    def close
      unless @tmp_file.nil?
        @tmp_file.close; @tmp_file.unlink
        @tmp_file = nil
      end

      @data.clear
    end

    def data_size
      @data_wrtn
    end

    protected

    # An SMTP message is complete, if the SENDER, RCPT
    # and DATA information has been written.
    #
    def complete?
      !@sender.nil? && @recipients.size > 0 &&
        @data_wrtn > 0
    end

    def write_data(d)
      if @tmp_file.nil?
        @data << d
        @data_wrtn += d.length

        if @data_wrtn > MAX_DATA_IN_MEMORY
          # transfer to tmp file, as needed
          @tmp_file = Tempfile.new(SMTP_MESSAGE_TEMP_FILE_PREFIX)

          @data.each { |d1| @tmp_file.write(d1) }
          @data.clear
        end
      else
        @tmp_file.write(d)
        @data_wrtn += d.length
      end

      @data_wrtn
    end
  end
end
