module Magic
  module Cards
    EvendoBrushrazer = Creature("Evendo Brushrazer") do
      cost generic: 2, red: 1
      creature_type "Insect Warrior"
      power 3
      toughness 3
    end

    class EvendoBrushrazer < Creature
      class ExiledCardPermission < StaticAbility
        def permits_casting_from_exile?(card)
          game.current_turn.active_player == controller &&
            game.current_turn.events.any? do |event|
              event.is_a?(Events::PermanentSacrificed) &&
                event.permanent.controller == controller &&
                !event.permanent.token?
            end &&
            @source.exiled_cards.include?(card)
        end
      end

      class SacrificeTrigger < TriggeredAbility
        def should_perform?
          event.permanent.controller == controller && !event.permanent.token?
        end

        def call
          card = controller.library.first
          return unless card

          actor.exiled_cards << card
          card.exile!
        end
      end

      class LandManaAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice a land"

        def resolve!
          controller.add_mana(red: 2)
        end
      end

      def event_handlers = { Events::PermanentSacrificed => SacrificeTrigger }
      def static_abilities = [ExiledCardPermission]
      def activated_abilities = [LandManaAbility]
    end
  end
end