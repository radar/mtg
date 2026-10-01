module Magic
  module Cards
    MeticulousArtisan = Creature("Meticulous Artisan") do
      cost generic: 3, red: 1
      creature_type("Djinn Artificer")
      keywords :prowess
      power 3
      toughness 3
    end

    class MeticulousArtisan < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: Tokens::Treasure)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
