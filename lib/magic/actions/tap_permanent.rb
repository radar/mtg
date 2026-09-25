module Magic
  module Actions
    class TapPermanent < Action
      def uses_priority?
        false
      end

      attr_reader :permanent
      def initialize(permanent:, **args)
        @permanent = permanent
        super(**args)
      end

      def inspect
        "#<Actions::TapPermanent permanent: #{permanent.name}, player: #{player.inspect}>"
      end

      def perform
        permanent.tap!
      end
    end
  end
end
