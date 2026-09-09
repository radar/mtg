module Magic
  module Cards
    AugurOfAutumn = Creature("Augur of Autumn") do
      cost generic: 1, green: 2
      creature_type "Human Druid"
      power 3
      toughness 3
    end

    class AugurOfAutumn < Creature
      def additional_lands_per_turn = 1

      class TopLibraryPermission < StaticAbility
        def permits_casting_from_top?(card)
          return false unless card == controller.library.first
          return true if card.land?
          card.creature? && controller.creatures.map(&:power).uniq.count >= 3
        end
      end

      class TopCardRevealTrigger < TriggeredAbility
        def should_perform?
          (event.is_a?(Events::CardDraw) && event.player == controller) ||
            (event.is_a?(Events::EnteredTheBattlefield) && event.permanent.controller == controller)
        end

        def call
          controller.library.first&.reveal!
        end
      end

      def static_abilities = [TopLibraryPermission]

      def event_handlers
        {
          Events::CardDraw => TopCardRevealTrigger,
          Events::EnteredTheBattlefield => TopCardRevealTrigger,
        }
      end
    end
  end
end