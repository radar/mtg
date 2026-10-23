module Magic
  module Cards
    StormFleetSpy = Creature("Storm Fleet Spy") do
      cost generic: 2, blue: 1
      creature_type("Human Pirate")
      power 2
      toughness 2
    end

    class StormFleetSpy < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          super && declared_attackers_this_turn?
        end

        def call
          draw_card
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
