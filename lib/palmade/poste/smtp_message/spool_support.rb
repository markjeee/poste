module Palmade::Poste
  class SmtpMessage
    module SpoolSupport
      module ClassMethods
        def load_from_spool

        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      def load_from_spool

      end

      def write_to_spool

      end
    end
  end
end
