module Magic
  module Cards
    HeartfireHero = Creature("Heartfire Hero") do
      cost red: 1
      creature_type("Mouse Soldier")
      power 1
      toughness 1
    end

    class HeartfireHero < Creature
      class ValiantTrigger < TriggeredAbility::Valiant
        def call
          add_counter("+1/+1")
        end
      end

      def event_handlers = ValiantTrigger.handlers

      class DiesTrigger < TriggeredAbility::Death
        def call
          opponents.each { |opponent| deal_damage(actor.power, to: opponent) }
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
