module Palmade::Poste
  class MimeMessage
    module MongoSupport
      module ClassMethods
        def load_from_mongo

        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      def write_to_mongo

      end

      def load_from_mongo

      end
    end
  end
end
