module Magic
  module Cards
    FaithfulWatchdog = Creature("Faithful Watchdog") do
      cost green: 1, white: 1
      creature_type "Dog"
      power 0
      toughness 0
      keywords :vigilance
    end

    class FaithfulWatchdog < Creature
      # "This creature enters with three +1/+1 counters on it."
      class EntryCounters < Abilities::Static::AdditionalCountersForEntering
        def additional_counters_for_entering(permanent)
          permanent == source ? 3 : 0
        end
      end

      def static_abilities = [EntryCounters]
    end
  end
end
