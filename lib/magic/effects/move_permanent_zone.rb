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
        game.notify!(*leaving_zone_notifications(from: from, to: to))

        target.left_the_battlefield! if from&.battlefield?

        from&.remove(target)

        target.zone = to
        if to.battlefield?
          to.add(target)
          target.entered_the_battlefield!
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
