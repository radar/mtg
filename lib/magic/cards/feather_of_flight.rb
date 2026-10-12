module Magic
  module Cards
    FeatherOfFlight = Aura("Feather of Flight") do
      cost generic: 1, white: 1
      keywords :flash
    end

    class FeatherOfFlight < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      class EnchantedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 0
        applies_to_target
      end

      class EnchantedCreatureKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FLYING
        applies_to_target
      end

      def static_abilities = [EnchantedCreatureBuff, EnchantedCreatureKeywords]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:draw_card)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
