module Magic
  module Cards
    ShardmagesRescue = Aura("Shardmage's Rescue") do
      cost white: 1
      keywords :flash
    end

    class ShardmagesRescue < Aura
      enchant "Creature", you_control: true

      def target_choices
        controller.creatures
      end

      # "As long as this Aura entered this turn, enchanted creature has hexproof."
      class HexproofGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HEXPROOF

        def applicable_targets
          entered_this_turn = source.controlled_since_turn == game.current_turn&.number
          entered_this_turn && source.attached_to ? [source.attached_to] : []
        end
      end

      class EnchantedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      def static_abilities = [HexproofGrant, EnchantedCreatureBuff]
    end
  end
end
