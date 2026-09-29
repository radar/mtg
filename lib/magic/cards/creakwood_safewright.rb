module Magic
  module Cards
    class CreakwoodSafewright < Creature
      card_name "Creakwood Safewright"
      cost generic: 1, black: 1
      creature_type "Elf Warrior"
      power 5
      toughness 5
      enters_with_counters "-1/-1", 3

      # "At the beginning of your end step, if there is an Elf card in your graveyard and this
      # creature has a -1/-1 counter on it, remove a -1/-1 counter from this creature."
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && controller.graveyard.cards.any? { _1.type?("Elf") } &&
            actor.counters.of_type(Counters::Minus1Minus1).any?
        end

        def call
          actor.remove_counter(counter_type: Counters::Minus1Minus1)
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
