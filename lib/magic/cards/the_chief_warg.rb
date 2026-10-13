module Magic
  module Cards
    TheChiefWarg = Creature("The Chief Warg") do
      cost "{2}{B}{G}"
      legendary_creature_type "Wolf"
      keywords :menace
      power 3
      toughness 3
    end

    class TheChiefWarg < Creature
      # "Ferocious -- Whenever you attack while you control a creature with power 4 or greater, you draw a card and lose
      # 1 life."
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && event.attacks.any? && controller.creatures.any? { _1.power >= 4 }
        end

        def call
          draw_card
          lose_life(controller, 1)
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttackTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
