module Magic
  module Cards
    CryptidInspector = Creature("Cryptid Inspector") do
      cost generic: 2, green: 1
      creature_type "Elf Warrior"
      keywords :vigilance
      power 2
      toughness 3
    end

    class CryptidInspector < Creature
      # "Whenever a face-down permanent you control enters and whenever this creature or another permanent you control is
      # turned face up, put a +1/+1 counter on this creature."
      class EntersTrigger < TriggeredAbility
        def should_perform?
          event.permanent.face_down? && event.permanent.controller == controller
        end

        def call
          add_counter("+1/+1")
        end
      end

      class TurnedFaceUpTrigger < TriggeredAbility
        def should_perform?
          event.player == controller
        end

        def call
          add_counter("+1/+1")
        end
      end

      def event_handlers
        { Events::EnteredTheBattlefield => EntersTrigger, Events::TurnedFaceUp => TurnedFaceUpTrigger }
      end
    end
  end
end
