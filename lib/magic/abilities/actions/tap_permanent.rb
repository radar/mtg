module Magic
  module Actions
    class TapPermanent < Action
      attr_reader :permanent
      def initialize(permanent:, **args)
        @permanent = permanent
        super(**args)
      end

      def inspect
        "#<Actions::TapPermanent permanent: #{permanent.name}>"
      end

      def perform
        permanent.tap!
        game.notify!(
          Events::PermanentTapped.new(
            permanent: permanent
          )
        )
      end
    end
  end
end
