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
          create_token(token: Tokens::Treasure)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
