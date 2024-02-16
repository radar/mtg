module Magic
  module Events
    class Base
      attr_reader :source
      def initialize(source: nil)
        @source = source
      end
    end
  end
end
