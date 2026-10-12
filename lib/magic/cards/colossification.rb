module Magic
  module Cards
    Colossification = Aura("Colossification") do
      cost generic: 5, green: 2
    end

    class Colossification < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      class EnchantedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 20, toughness: 20
        applies_to_target
      end

      def static_abilities = [EnchantedCreatureBuff]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:tap, target: actor.attached_to)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
