module Magic
  module Cards
    class ReluctantDounguard < Creature
      card_name "Reluctant Dounguard"
      cost generic: 2, white: 1
      creature_type "Kithkin Soldier"
      power 4
      toughness 4
      enters_with_counters "-1/-1", 2

      # "Whenever another creature you control enters while this creature has a -1/-1 counter on it,
      # remove a -1/-1 counter from this creature."
      class CreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control? && actor.counters.of_type(Counters::Minus1Minus1).any?
        end

        def call
          actor.remove_counter(counter_type: Counters::Minus1Minus1)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => CreatureEntersTrigger }
    end
  end
end
