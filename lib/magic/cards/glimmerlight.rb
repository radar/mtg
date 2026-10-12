module Magic
  module Cards
    Glimmerlight = Equipment("Glimmerlight") do
      cost generic: 2
      equip [Costs::Mana.new(generic: 1)]
    end

    class Glimmerlight < Equipment
      # "When this Equipment enters, create a 1/1 white Glimmer enchantment creature token."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: GlimmerSeeker::GlimmerToken)
        end
      end

      # "Equipped creature gets +1/+1."
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      def etb_triggers = [EntersTrigger]

      def static_abilities = [EquippedCreatureBuff]
    end
  end
end
