module Magic
  module Cards
    EastMarkCavalier = Creature("East-Mark Cavalier") do
      cost generic: 1, white: 1
      creature_type "Human Knight"
      power 2
      toughness 2
      keywords :vigilance
    end

    class EastMarkCavalier < Creature
      # "Whenever this creature deals damage to a Goblin or Orc, destroy that creature."
      class DamageTrigger < TriggeredAbility
        def should_perform?
          target = event.target
          event.source == actor && target.is_a?(Magic::Permanent) && target.creature? &&
            (target.type?("Goblin") || target.type?("Orc"))
        end

        def call
          destroy(event.target)
        end
      end

      def event_handlers = { Events::DamageDealt => DamageTrigger }
    end
  end
end
