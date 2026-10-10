module Magic
  module Cards
    FearOfFailedTests = Creature("Fear of Failed Tests") do
      cost generic: 4, blue: 1
      enchantment_creature_type("Nightmare")
      power 2
      toughness 7
    end

    class FearOfFailedTests < Creature
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.is_a?(Magic::Player)
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: event.damage)
        end
      end

      def event_handlers = super.merge({ Events::CombatDamageDealt => CombatDamageTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
