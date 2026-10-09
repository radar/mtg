module Magic
  module Cards
    OldFatSpider = Creature("Old Fat Spider") do
      cost generic: 4, green: 2
      creature_type "Spider"
      keywords :reach
      power 6
      toughness 7
    end

    class OldFatSpider < Creature
      # "This creature can't be blocked by creatures with power 2 or less."
      def can_be_blocked?(blocker) = blocker.power > 2

      # "Whenever this creature becomes the target of a spell or ability an opponent controls, draw a card."
      class TargetedBySpellTrigger < TriggeredAbility::SpellCast
        def should_perform?
          opponents.include?(event.player) && event.targets.include?(actor)
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      class TargetedByAbilityTrigger < TriggeredAbility
        def should_perform?
          opponents.include?(event.player) && event.targets.include?(actor)
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def event_handlers
        super.merge({
          Events::SpellCast => TargetedBySpellTrigger,
          Events::AbilityActivated => TargetedByAbilityTrigger,
        }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
