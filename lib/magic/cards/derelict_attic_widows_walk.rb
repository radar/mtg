module Magic
  module Cards
    class DerelictAtticWidowsWalk < Room
      class DerelictAttic < Room::Door
        card_name "Derelict Attic"
        cost generic: 2, black: 1

        # "When you unlock this door, you draw two cards and you lose 2 life."
        when_unlocked do
          draw_cards(2)
          lose_life(controller, 2)
        end
      end

      class WidowsWalk < Room::Door
        card_name "Widow's Walk"
        cost generic: 3, black: 1

        # "Whenever a creature you control attacks alone, it gets +1/+0 and gains deathtouch until end of turn."
        class AttacksAloneTrigger < TriggeredAbility
          def should_perform?
            event.active_player == controller && event.attacks.one? && event.attacks.first.attacker.controller == controller
          end

          def call
            attacker = event.attacks.first.attacker
            pump(attacker, 1, 0)
            attacker.grant_keyword(Cards::Keywords::DEATHTOUCH, until_eot: true)
          end
        end

        def event_handlers = { Events::FinalAttackersDeclared => AttacksAloneTrigger }
      end

      doors DerelictAttic, WidowsWalk
    end
  end
end
