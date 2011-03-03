# -*- encoding: binary -*-
#
# This code is based and shamelessly stolen from EM::Protocols::LineText2
#
# require 'em/protocols/linetext2'
#
module Palmade::Poste
  class SmtpClientConnection
    module LineText2
      MaxLineLength = 16 * 1024
      MaxBinaryLength = 32 * 1024 * 1024

      Cnewline = "\n".freeze
      Cempty = "".freeze
      Cbinary = Encoding.find('binary')

      def receive_data(data)
        return unless (data && data.length > 0)

        # force BINARY encoding, we don't want anything to do
        # with the encoding of the data, let the apps deal with it.
        data.force_encoding(Cbinary)

        # Do this stuff in lieu of a constructor.
        @lt2_mode ||= :lines
        @lt2_delimiter ||= Cnewline
        @lt2_linebuffer ||= [ ]

        if @lt2_mode == :lines
          if ix = data.index(@lt2_delimiter)
            @lt2_linebuffer << data[0...ix]

            ln = @lt2_linebuffer.join
            @lt2_linebuffer.clear

            if @lt2_delimiter == Cnewline
              ln.chomp!
            end

            receive_line ln
            receive_data data[(ix + @lt2_delimiter.length)..-1]
          else
            @lt2_linebuffer << data
          end
        elsif @lt2_mode == :text
          if @lt2_textsize
            needed = @lt2_textsize - @lt2_textpos

            will_take = if data.length > needed
                          needed
                        else
                          data.length
                        end

            @lt2_textbuffer << data[0...will_take]
            tail = data[will_take..-1]

            @lt2_textpos += will_take
            if @lt2_textpos >= @lt2_textsize
              set_line_mode

              receive_binary_data @lt2_textbuffer.join
              receive_end_of_binary_data
            end

            receive_data tail
          else
            receive_binary_data data
          end
        end
      end

      def set_delimiter(delim)
        @lt2_delimiter = delim.to_s
      end

      def set_line_mode(data = Cempty)
        @lt2_mode = :lines
        (@lt2_linebuffer ||= []).clear
        receive_data data.to_s
      end

      def set_text_mode(size = nil)
        if size == 0
          set_line_mode
        else
          @lt2_mode = :text
          (@lt2_textbuffer ||= []).clear
          @lt2_textsize = size # which can be nil, signifying no limit
          @lt2_textpos = 0
        end
      end

      def set_binary_mode(size = nil)
        set_text_mode size
      end

      def unbind
        @lt2_mode ||= nil
        if @lt2_mode == :text and @lt2_textpos > 0
          receive_binary_data @lt2_textbuffer.join
        end
      end

      # Stub. Should be subclassed by user code.
      def receive_line(ln)
        # no-op
      end

      # Stub. Should be subclassed by user code.
      def receive_binary_data(data)
        # no-op
      end

      # Stub. Should be subclassed by user code.
      def receive_end_of_binary_data
        # no-op
      end

    end
  end
end
