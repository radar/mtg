module Magic
  module Cards
    FireRimForm = Aura("Fire-Rim Form") do
      cost generic: 1, red: 1
      keywords :flash
    end

    class FireRimForm < Aura
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
          give_keyword(actor.attached_to, :first_strike)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
