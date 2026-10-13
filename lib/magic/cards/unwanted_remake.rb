module Magic
  module Cards
    UnwantedRemake = Instant("Unwanted Remake") do
      cost white: 1
    end

    class UnwantedRemake < Instant
      def single_target? = true

      def target_choices
        battlefield.creatures
      end

      # "Destroy target creature. Its controller manifests dread."
      def resolve!(target:)
        victim = target.controller
        destroy(target)
        Magic::Choice::ManifestDread.perform(actor: self, player: victim)
      end
    end
  end
end
