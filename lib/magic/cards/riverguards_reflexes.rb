module Magic
  module Cards
    RiverguardsReflexes = Instant("Riverguard's Reflexes") do
      cost generic: 1, white: 1
    end

    class RiverguardsReflexes < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        pump(target, 2, 2)
        give_keyword(target, :first_strike)
        target.untap!
      end
    end
  end
end
