module Magic
  module Cards
    NivMizzetVisionary = Creature("Niv-Mizzet, Visionary") do
      cost generic: 4, blue: 1, red: 1
      legendary_creature_type("Dragon Wizard")
      keywords :flying
      power 5
      toughness 5
    end

    class NivMizzetVisionary < Creature
      def no_maximum_hand_size? = true

      class NoncombatDamageToOpponentTrigger < TriggeredAbility
        def should_perform?
          !event.combat? && event.target.is_a?(Magic::Player) && event.target != controller && event.source.respond_to?(:controller) && event.source.controller == controller
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: event.damage)
        end
      end

      def event_handlers = { Events::DamageDealt => NoncombatDamageToOpponentTrigger }
    end
  end
end
