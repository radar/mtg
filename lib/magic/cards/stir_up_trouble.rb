module Magic
  module Cards
    class StirUpTrouble < Sorcery
      card_name "Stir Up Trouble"
      cost black: 1

      # "As an additional cost to cast this spell, sacrifice an artifact or creature or pay {4}."
      def additional_costs
        [Costs::SacrificeOrMana.new(self, types: ["Artifact", "Creature"], mana_cost: { generic: 4 })]
      end

      def single_target?
        true
      end

      def target_choices = battlefield.creatures

      def resolve!(target:)
        trigger_effect(:destroy_target, target: target)
      end
    end
  end
end
