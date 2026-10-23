module Magic
  module Cards
    DreamtideWhale = Creature("Dreamtide Whale") do
      cost generic: 2, blue: 1
      creature_type "Whale"
      power 7
      toughness 5
      enters_with_counters "time", 2
    end

    class DreamtideWhale < Creature
      # Vanishing 2: "At the beginning of your upkeep, remove a time counter from it. When the last is removed,
      # sacrifice it."
      class VanishingTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def should_perform? = super && actor.counters.of_type(Counters::Time).any?

        def call
          actor.remove_counter(counter_type: Counters::Time)
          actor.sacrifice! if actor.counters.of_type(Counters::Time).none?
        end
      end

      # "Whenever a player casts their second spell each turn, proliferate."
      class SecondSpellTrigger < TriggeredAbility::SpellCast
        def should_perform? = second_spell_this_turn?

        def call
          proliferate
        end
      end

      def event_handlers
        handlers = super
        handlers.merge(
          Events::BeginningOfUpkeep => VanishingTrigger,
          Events::SpellCast => [*handlers[Events::SpellCast], SecondSpellTrigger]
        )
      end
    end
  end
end
