module Magic
  module Cards
    AcademyElite = Creature("Academy Elite") do
      cost generic: 3, blue: 1
      creature_type("Human Wizard")
      power 0
      toughness 0
    end

    class AcademyElite < Creature
      # Oracle text: "This creature enters with X +1/+1 counters on it..." -- a
      # replacement effect, not a triggered ability. Matters because it's a 0/0: a
      # triggered-ability implementation dies to state-based actions (0 toughness)
      # before its own ETB trigger ever gets a chance to resolve and add counters.
      class EntryCounters < Abilities::Static::AdditionalCountersForEntering
        def additional_counters_for_entering(permanent)
          return 0 unless permanent == source

          game.graveyard_cards.by_any_type(T::Instant, T::Sorcery).count
        end
      end

      def static_abilities = [EntryCounters]

      class ActivatedAbility < ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 2, blue: 1),
            Costs::RemoveCounter.new(source, Counters::Plus1Plus1),
          ]
        end

        def resolve!
          trigger_effect(:draw_cards, source: source)
          add_choice(:discard)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
