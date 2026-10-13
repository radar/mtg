module Magic
  module Cards
    InspiringOverseer = Creature("Inspiring Overseer") do
      cost generic: 2, white: 1
      creature_type("Angel Cleric")
      keywords :flying
      power 2
      toughness 1
    end

    class InspiringOverseer < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_life(1)
          draw_card
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
