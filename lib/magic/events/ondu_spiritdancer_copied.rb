module Magic
  module Events
    class OnduSpiritdancerCopied
      attr_reader :actor

      def initialize(actor:)
        @actor = actor
      end
    end
  end
end