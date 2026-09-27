module Magic
  module Cards
    class WildUnraveling < Instant
      card_name "Wild Unraveling"
      cost blue: 2

      def additional_costs
        [Costs::BlightOrMana.new(self, blight_amount: 2, mana_cost: { generic: 1 })]
      end

      def target_choices
        game.stack.spells
      end

      def resolve!(target:)
        trigger_effect(:counter_spell, target: target)
      end
    end
  end
end
