module Magic
  module Cards
    WardenOfTheWoods = Creature("Warden of the Woods") do
      cost generic: 4, green: 2
      creature_type "Treefolk"
      keywords :vigilance
      power 5
      toughness 7
    end

    class WardenOfTheWoods < Creature
      class TargetedBySpellTrigger < TriggeredAbility::SpellCast
        def should_perform?
          opponents.include?(event.player) && event.targets.include?(actor)
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 2)
        end
      end

      class TargetedByAbilityTrigger < TriggeredAbility
        def should_perform?
          opponents.include?(event.player) && event.targets.include?(actor)
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 2)
        end
      end

      def event_handlers
        {
          Events::SpellCast => TargetedBySpellTrigger,
          Events::AbilityActivated => TargetedByAbilityTrigger,
        }
      end
    end
  end
end
