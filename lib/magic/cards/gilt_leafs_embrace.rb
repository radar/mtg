module Magic
  module Cards
    GiltLeafsEmbrace = Aura("Gilt-Leaf's Embrace") do
      cost generic: 2, green: 1
      keywords :flash
    end

    class GiltLeafsEmbrace < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      class EnchantedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 0
        applies_to_target
      end

      def static_abilities = [EnchantedCreatureBuff]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:grant_keyword, target: actor.attached_to, keyword: :trample)
          trigger_effect(:grant_keyword, target: actor.attached_to, keyword: :indestructible)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
