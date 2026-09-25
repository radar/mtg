module Magic
  module Cards
    ZinniaValleysVoice = Creature("Zinnia, Valley's Voice") do
      cost "{U}{R}{W}"
      legendary_creature_type "Bird Bard"
      power 1
      toughness 3
      keywords :flying
    end

    class ZinniaValleysVoice < Creature
      # "Zinnia gets +X/+0, where X is the number of other creatures you control with base power 1."
      class PowerBoost < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification
          (source.controller.creatures - [source]).count { |creature| creature.base_power == 1 }
        end
      end

      # "Creature spells you cast gain offspring {2} as you cast them."
      class CreatureSpellsGainOffspring < Abilities::Static::GrantOffspring
        def offspring_cost_for(card, player)
          { generic: 2 } if card.creature? && player == controller
        end
      end

      def static_abilities = [PowerBoost, CreatureSpellsGainOffspring]
    end
  end
end
