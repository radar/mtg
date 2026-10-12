module Magic
  module Cards
    InquisitiveGlimmer = Creature("Inquisitive Glimmer") do
      enchantment_creature_type("Fox Glimmer")
      cost white: 1, blue: 1
      power 2
      toughness 3
    end

    class InquisitiveGlimmer < Creature
      # "Enchantment spells you cast cost {1} less to cast."
      class ReduceEnchantmentCosts < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: -1 }
        end

        def applies_to?(card) = card.enchantment? && card.controller == source.controller
      end

      # "Unlock costs you pay cost {1} less."
      class ReduceUnlockCosts < StaticAbility
        def unlock_cost_adjustment(_door, player)
          { generic: -1 } if player == controller
        end
      end

      def static_abilities = [ReduceEnchantmentCosts, ReduceUnlockCosts]
    end
  end
end
