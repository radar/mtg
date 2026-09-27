module Magic
  module Cards
    class BogslithersEmbrace < Sorcery
      card_name "Bogslither's Embrace"
      cost generic: 1, black: 1

      def additional_costs
        [Costs::BlightOrMana.new(self, blight_amount: 1, mana_cost: { generic: 3 })]
      end

      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:exile, target: target)
      end
    end
  end
end
