module Magic
  module Cards
    StalactiteDagger = Equipment("Stalactite Dagger") do
      cost generic: 2
      equip [Costs::Mana.new(generic: 2)]
    end

    class StalactiteDagger < Equipment
      def grants_all_creature_types? = true

      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        ShapeshifterToken = Token.create "Shapeshifter" do
          creature_type "Shapeshifter"
          power 1
          toughness 1
          keywords :changeling
        end

        def call
          trigger_effect(:create_token, token_class: ShapeshifterToken)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
