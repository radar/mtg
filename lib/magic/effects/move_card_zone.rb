module Magic
  module Effects
    class MoveCardZone < TargetedEffect
      attr_reader :from, :to, :placement

      def initialize(from:, to:, placement: 0, **args)
        super(**args)
        @target = target
        @from = from
        @to = to
        @placement = placement
      end

      def inspect
        "#<Effects::MoveCardZone target:#{target.name} from:#{from&.name} to:#{to.name}>"
      end

      def resolve!
        if from
          game.notify!(
            Events::CardLeavingZoneTransition.new(
              target,
              from: from,
              to: to
            )
          )

          from.remove(target)
        end

        target.zone = to
        unless to.battlefield?
          to.add(target, placement)
        end

        game.notify!(
          Events::CardEnteredZoneTransition.new(
            target,
            from: from,
            to: to
          )
        )
      end
    end
  end
end
