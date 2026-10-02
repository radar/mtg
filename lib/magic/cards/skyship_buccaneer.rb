module Magic
  module Cards
    SkyshipBuccaneer = Creature("Skyship Buccaneer") do
      cost generic: 3, blue: 2
      creature_type("Human Pirate")
      keywords :flying
      power 4
      toughness 3
    end

    class SkyshipBuccaneer < Creature
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
