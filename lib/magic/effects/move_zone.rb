module Magic
  module Effects
    class MoveZone < TargetedEffect
      attr_reader :destination

      def initialize(destination:, **args)
        @destination = destination
        super(**args)
      end

      def inspect
        "#<Effects::MoveZone target:#{target} zone:#{destination.name}>"
      end

      def resolve!
        original_zone = target.zone
        target.move_zone!(destination)
        if destination.battlefield?
          Permanent.resolve(game: game, card: target, from_zone: original_zone)
        end
      end
    end
  end
end
