module Magic
  module Cards
    EvendoBrushrazer = Creature("Evendo Brushrazer") do
      cost generic: 2, red: 1
      creature_type "Insect Warrior"
      power 3
      toughness 3
    end

    class EvendoBrushrazer < Creature
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
      def activated_abilities = [LandManaAbility]
    end
  end
end