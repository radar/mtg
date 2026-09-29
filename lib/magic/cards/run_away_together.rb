module Magic
  module Cards
    RunAwayTogether = Instant("Run Away Together") do
      cost generic: 1, blue: 1

      def multi_target? = true

      def distinct_targets? = true

      def target_choices
        [battlefield.creatures, battlefield.creatures]
      end

      # Choose two target creatures controlled by different players.
      def targets_legal?(targets)
        targets.map(&:controller).uniq.size == targets.size
      end

      # Return those creatures to their owners' hands.
      def resolve!(targets:)
        targets.each(&:return_to_hand)
      end
    end
  end
end
