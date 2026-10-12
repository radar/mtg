module Magic
  module Cards
    class PaintersStudioDefacedGallery < Room
      class PaintersStudio < Room::Door
        card_name "Painter's Studio"
        cost generic: 2, red: 1

        # "When you unlock this door, exile the top two cards of your library. You may play them until the end of your next
        # turn."
        when_unlocked do
          controller.library.first(2).each do |card|
            card.exile!
            game.play_permissions.grant_until_end_of_next_turn(card: card, player: controller)
          end
        end
      end

      class DefacedGallery < Room::Door
        card_name "Defaced Gallery"
        cost generic: 1, red: 1

        # "Whenever you attack, attacking creatures you control get +1/+0 until end of turn."
        class AttackTrigger < TriggeredAbility
          def should_perform? = event.active_player == controller && event.attacks.any?

          def call
            event.attacks.map(&:attacker).select { _1.controller == controller }.each do |attacker|
              pump(attacker, 1, 0)
            end
          end
        end

        def event_handlers = { Events::FinalAttackersDeclared => AttackTrigger }
      end

      doors PaintersStudio, DefacedGallery
    end
  end
end
