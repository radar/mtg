module Magic
  module Cards
    AHeartfireHero = Creature("A-Heartfire Hero") do
      cost red: 1
      creature_type("Mouse Soldier")
      power 0
      toughness 1
    end

    class AHeartfireHero < Creature
      # Valiant -- put a +1/+1 counter on it.
      class ValiantTrigger < TriggeredAbility::Valiant
        def call
          add_counter("+1/+1")
        end
      end

      def event_handlers = super.merge(ValiantTrigger.handlers)

      # When this creature dies, it deals damage equal to its power to each opponent.
      class DiesTrigger < TriggeredAbility::Death
        def call
          opponents.each { |opponent| deal_damage(actor.power, to: opponent) }
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
