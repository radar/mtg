module Magic
  module Cards
    TitansVanguard = Creature("Titans' Vanguard") do
      cost generic: 3, red: 1, green: 1
      creature_type "Eldrazi"
      power 5
      toughness 5
      keywords :devoid, :trample
    end

    class TitansVanguard < Creature
      # "...put a +1/+1 counter on each colorless creature you control."
      module CountersOnColorless
        def put_counters
          controller.creatures.select(&:colorless?).each { add_counter("+1/+1", to: _1) }
        end
      end

      # "When you cast this spell, ..."
      class CastTrigger < TriggeredAbility::CastThisSpell
        include CountersOnColorless

        def call = put_counters
      end

      # "...and whenever this creature attacks, ..."
      class AttackTrigger < TriggeredAbility
        include CountersOnColorless

        def should_perform? = event.attack.attacker == actor

        def call = put_counters
      end

      def cast_triggers = [CastTrigger]
      def event_handlers = { Events::AttackDeclared => AttackTrigger }
    end
  end
end
