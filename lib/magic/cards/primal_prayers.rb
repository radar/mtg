module Magic
  module Cards
    PrimalPrayers = Enchantment("Primal Prayers") do
      cost generic: 2, green: 2
    end

    class PrimalPrayers < Enchantment
      # When this enchantment enters, you get {E}{E}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 2
        end
      end

      # "You may cast creature spells with mana value 3 or less by paying {E} rather than paying their mana costs. If you
      # cast a spell this way, you may cast it as though it had flash." Cast with `pay_static_alternative: true` to use it.
      class PayEnergyInstead < StaticAbility
        def alternative_cost_for(card, player)
          return unless player == controller && card.creature? && card.mana_value <= 3

          Costs::EnergyAlternativeCost.new(amount: 1, grants_flash: true)
        end
      end

      def etb_triggers = [EntersTrigger]

      def static_abilities = [PayEnergyInstead]
    end
  end
end
