module Magic
  module Cards
    FellingBlow = Sorcery("Felling Blow") do
      cost generic: 2, green: 1
    end

    class FellingBlow < Sorcery
      def multi_target? = true

      def target_choices
        [battlefield.controlled_by(controller).creatures, battlefield.not_controlled_by(controller).creatures]
      end

      def resolve!(targets:)
        biter, victim = targets
        add_counter("+1/+1", to: biter)
        biter.bite!(victim)
      end
    end
  end
end
