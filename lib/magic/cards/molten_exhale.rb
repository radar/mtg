module Magic
  module Cards
    MoltenExhale = Sorcery("Molten Exhale") do
      cost generic: 1, red: 1
    end

    class MoltenExhale < Sorcery
      # You may behold a Dragon as an additional cost to cast this spell.
      def kicker_cost
        @behold_cost ||= Costs::OptionalBehold.new(self, type: "Dragon", grants_flash: true)
      end

      def target_choices
        battlefield.creatures + battlefield.planeswalkers
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 4)
      end
    end
  end
end
