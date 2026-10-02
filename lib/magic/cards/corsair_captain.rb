module Magic
  module Cards
    CorsairCaptain = Creature("Corsair Captain") do
      cost generic: 2, blue: 1
      creature_type("Human Pirate")
      power 2
      toughness 2
    end

    class CorsairCaptain < Creature
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        other_creatures "Pirate"
      end

      def static_abilities = [PowerAndToughnessModification]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: Tokens::Treasure)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
