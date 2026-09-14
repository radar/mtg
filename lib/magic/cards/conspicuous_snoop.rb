module Magic
  module Cards
    ConspicuousSnoop = Creature("Conspicuous Snoop") do
      cost red: 2
      creature_type "Goblin Rogue"
      power 2
      toughness 2
    end

    class ConspicuousSnoop < Creature
      class TopLibraryPermission < StaticAbility
        def permits_casting_from_top?(card)
          card == controller.library.first && card.type?("Goblin")
        end
      end

      class GrantTopGoblinAbilities < Abilities::Static::GrantActivatedAbilities
        def applies_to?(permanent)
          permanent == @source && top_goblin_card
        end

        def granted_abilities
          top_goblin_card.activated_abilities
        end

        private

        def top_goblin_card
          card = controller.library.first
          card if card&.type?("Goblin")
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

      def static_abilities = [TopLibraryPermission, GrantTopGoblinAbilities]

      def event_handlers
        {
          Events::CardDraw => TopCardRevealTrigger,
          Events::EnteredTheBattlefield => TopCardRevealTrigger,
        }
      end
    end
  end
end
