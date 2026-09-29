module Magic
  module Cards
    class EncumberedReejerey < Creature
      card_name "Encumbered Reejerey"
      cost generic: 1, white: 1
      creature_type "Merfolk Soldier"
      power 5
      toughness 4
      enters_with_counters "-1/-1", 3

      # "Whenever this creature becomes tapped while it has a -1/-1 counter on it, remove a -1/-1
      # counter from it."
      class TappedTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor && actor.counters.of_type(Counters::Minus1Minus1).any?
        end

        def call
          actor.remove_counter(counter_type: Counters::Minus1Minus1)
        end
      end

      def event_handlers = { Events::PermanentTapped => TappedTrigger }
    end
  end
end
