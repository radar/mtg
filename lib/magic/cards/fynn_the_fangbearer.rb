module Magic
  module Cards
    FynnTheFangbearer = Creature("Fynn, the Fangbearer") do
      cost generic: 1, green: 1
      legendary_creature_type("Human Warrior")
      keywords :deathtouch
      power 1
      toughness 3
    end

    class FynnTheFangbearer < Creature
      class KeywordCreatureCombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source.is_a?(Magic::Permanent) && event.source.creature? && event.source.controller == controller && event.source.deathtouch? && event.target.is_a?(Magic::Player)
        end

        def call
          [that_player].each { add_counter("poison", to: _1, amount: 2) }
        end
      end

      def event_handlers = { Events::CombatDamageDealt => KeywordCreatureCombatDamageTrigger }
    end
  end
end
