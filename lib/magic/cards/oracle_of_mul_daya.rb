module Magic
  module Cards
    OracleOfMulDaya = Creature("Oracle of Mul Daya") do
      cost generic: 3, green: 1
      creature_type "Elf Shaman"
      power 2
      toughness 2
    end

    class OracleOfMulDaya < Creature
      def additional_lands_per_turn = 1

      class TopCardRevealTrigger < TriggeredAbility
        def should_perform?
          (event.is_a?(Events::CardDraw) && event.player == controller) ||
            (event.is_a?(Events::EnteredTheBattlefield) && event.permanent.controller == controller)
        end

        def call
          controller.library.first&.reveal!
        end
      end

      def etb_triggers = [TopCardRevealTrigger]

      def event_handlers
        {
          Events::CardDraw => TopCardRevealTrigger,
          Events::EnteredTheBattlefield => TopCardRevealTrigger,
        }
      end
    end
  end
end