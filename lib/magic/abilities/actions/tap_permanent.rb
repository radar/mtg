module Magic
  module Actions
    class TapPermanent < Action
      attr_reader :permanent
      def initialize(permanent:, **args)
        @permanent = permanent
        super(**args)
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
