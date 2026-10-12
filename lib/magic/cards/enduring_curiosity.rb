module Magic
  module Cards
    EnduringCuriosity = Creature("Enduring Curiosity") do
      cost generic: 2, blue: 2
      enchantment_creature_type("Cat Glimmer")
      keywords :flash
      power 4
      toughness 3
    end

    class EnduringCuriosity < Creature
      # "Whenever a creature you control deals combat damage to a player, draw a card."
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.target.is_a?(Magic::Player) && event.source.respond_to?(:creature?) && event.source.creature? &&
            event.source.controller == controller
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def event_handlers = { Events::CombatDamageDealt => CombatDamageTrigger }

      def death_triggers = [TriggeredAbility::EnduringReturn]
    end
  end
end
