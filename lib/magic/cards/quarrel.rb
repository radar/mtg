module Magic
  module Cards
    Quarrel = Instant("Quarrel") do
      cost generic: 1, green: 1
    end

    class Quarrel < Instant
      def multi_target? = true

      def target_choices
        [battlefield.controlled_by(controller).creatures, battlefield.not_controlled_by(controller).creatures]
      end

      def resolve!(targets:)
        biter, victim = targets
        biter.bite!(victim)
      end
    end
  end
end
