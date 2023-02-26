module Magic
  module ZoneTransitions
    class Permanent
      extend Forwardable
      def_delegators :@permanent, :card, :land?, :token?

      attr_reader :game, :permanent, :from, :to


      def self.perform(...)
        new(...).perform
      end

      def initialize(game:, permanent:, from: permanent.zone, to:)
        @game = game
        @permanent = permanent
        @from = from
        @to = to
      end

      def perform
        if from
          send_leaving_zone_notification
          permanent.left_zone! if from.battlefield?
        end

        case [from, to]
        in [Zones::Battlefield, _]
          from_battlefield
        in [_, Zones::Battlefield]
          to_battlefield
        end

        send_entered_zone_notification
      end

      private

      def from_battlefield
        from.remove(permanent) if from
        to.add(card) unless token?
      end

      def to_battlefield
        to.add(permanent)
        from.remove(card) if from
      end

      def send_leaving_zone_notification
        game.notify!(*Events::PermanentLeavingZoneTransition.new(permanent, from: from, to: to))
      end

      def send_entered_zone_notification
        game.notify!(*
          Events::PermanentEnteredZoneTransition.new(
            permanent,
            from: from,
            to: to
          )
        )
      end
    end
  end
end
