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
          super && (game.current_turn.events.any? { |e| e.is_a?(Events::FinalAttackersDeclared) && e.active_player == controller && e.attacks.any? })
        end

        def call
          trigger_effect(:draw_card)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
