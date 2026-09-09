module Magic
  module Events
    class OnduSpiritdancerCopied
      attr_reader :dancer

      def initialize(dancer:)
        @dancer = dancer
      end
    end
  end
end