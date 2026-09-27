module Magic
  module Cards
    FlamekinGildweaver = Creature("Flamekin Gildweaver") do
      cost generic: 3, red: 1
      creature_type("Elemental Sorcerer")
      keywords :trample
      power 4
      toughness 3
    end

    class FlamekinGildweaver < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: Tokens::Treasure)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
