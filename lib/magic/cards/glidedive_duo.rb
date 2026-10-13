module Magic
  module Cards
    GlidediveDuo = Creature("Glidedive Duo") do
      cost generic: 4, black: 1
      creature_type("Bat Lizard")
      keywords :flying
      power 3
      toughness 3
    end

    class GlidediveDuo < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.opponents(controller).each { lose_life(_1, 2) }
          gain_life(2)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
