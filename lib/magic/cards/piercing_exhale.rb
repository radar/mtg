module Magic
  module Cards
    PiercingExhale = Instant("Piercing Exhale") do
      cost generic: 1, green: 1
    end

    class PiercingExhale < Instant
      # You may behold a Dragon as an additional cost to cast this spell.
      def kicker_cost
        @behold_cost ||= Costs::OptionalBehold.new(self, type: "Dragon")
      end

      def multi_target? = true

      def target_choices
        [battlefield.controlled_by(controller).creatures, (battlefield.creatures + battlefield.planeswalkers)]
      end

      def resolve!(targets:)
        biter, victim = targets
        biter.bite!(victim)
        if kicker_cost.paid?
          game.choices.add(Magic::Choice::Surveil.new(actor: self, amount: 2))
        end
      end
    end
  end
end
