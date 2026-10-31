module Magic
  module Cards
    class LashOfTheBalrog < Sorcery
      card_name "Lash of the Balrog"
      cost black: 1

      # "As an additional cost to cast this spell, sacrifice a creature or pay {4}."
      def additional_costs
        [Costs::SacrificeOrMana.new(self, types: ["Creature"], mana_cost: { generic: 4 })]
      end

      def single_target? = true

      def target_choices = battlefield.creatures

      # "Destroy target creature."
      def resolve!(target:)
        destroy(target)
      end
    end
  end
end
