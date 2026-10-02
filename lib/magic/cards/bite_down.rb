module Magic
  module Cards
    BiteDown = Instant("Bite Down") do
      cost generic: 1, green: 1
    end

    class BiteDown < Instant
      def multi_target? = true

      def target_choices
        [battlefield.controlled_by(controller).creatures, (battlefield.not_controlled_by(controller).creatures + battlefield.not_controlled_by(controller).planeswalkers)]
      end

      def resolve!(targets:)
        biter, victim = targets
        biter.bite!(victim)
      end
    end
  end
end
