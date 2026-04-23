module Magic
  module Effects
    class MovePermanentZone < TargetedEffect
      attr_reader :from, :to, :permanent

      def initialize(from:, to:, **args)
        super(**args)
        @permanent = target
        @from = from
        @to = to
      end

      def inspect
        "#<Effects::MovePermanentZone permanent:#{target.name} from:#{from&.name} to:#{to.name}>"
      end

      def resolve!
        if to.battlefield?
          game.notify!(
            Events::WillEnterTheBattlefield.new(
              target,
              from: from,
              to: to,
            )
          )
        end

        game.notify!(*leaving_zone_notifications(from: from, to: to))

        game.unsubscribe(target) if from&.battlefield?

        from&.remove(target)

        target.zone = to
        if to.battlefield?
          to.add(target)
          game.subscribe(target)
          target.apply_continuous_effects!
        end

        game.notify!(*entering_zone_notifications(from: from, to: to))
      end

      def leaving_zone_notifications(from:, to:)
        Events::PermanentLeavingZoneTransition.new(
          target,
          from: from,
          to: to
        )
      end

      def entering_zone_notifications(from:, to:)
        Events::PermanentEnteredZoneTransition.new(
          target,
          from: from,
          to: to
        )
      end
    end
  end
end
