module Magic
  module Cards
    SerraRedeemer = Creature("Serra Redeemer") do
      cost generic: 3, white: 2
      creature_type("Angel Soldier")
      keywords :flying
      power 2
      toughness 4
    end

    class SerraRedeemer < Creature
      # Whenever another creature you control with power 2 or less enters, put two +1/+1 counters on that creature.
      class SmallCreatureEnters < TriggeredAbility::EnterTheBattlefield
        def should_perform? = another_creature? && under_your_control? && event.permanent.power <= 2

        def call
          add_counter("+1/+1", target: event.permanent, amount: 2)
        end
      end

      def event_handlers = super.merge(Events::EnteredTheBattlefield => SmallCreatureEnters)
    end
  end
end
