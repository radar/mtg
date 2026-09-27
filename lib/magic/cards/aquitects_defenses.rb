module Magic
  module Cards
    AquitectsDefenses = Aura("Aquitect's Defenses") do
      cost generic: 1, blue: 1
      keywords :flash
    end

    class AquitectsDefenses < Aura
      enchant "Creature", you_control: true

      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      class EnchantedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 2
        applies_to_target
      end

      def static_abilities = [EnchantedCreatureBuff]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:grant_keyword, target: actor.attached_to, keyword: :hexproof)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
