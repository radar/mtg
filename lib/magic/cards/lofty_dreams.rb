module Magic
  module Cards
    LoftyDreams = Aura("Lofty Dreams") do
      cost generic: 3, blue: 2
      convoke
    end

    class LoftyDreams < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      class EnchantedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2
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
