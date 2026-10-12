module Magic
  module Cards
    class ValgavothsOnslaught < Sorcery
      card_name "Valgavoth's Onslaught"
      cost x: 1, green: 1

      # {X}{X}{G}: pay twice X, cast with `value_for_x: X`.
      def x_multiplier = 2

      # One of the X manifest dreads: tells the spell which creature it made, then goes on to the next.
      class ManifestChoice < Magic::Choice::ManifestDread
        def manifested(permanent)
          actor.dread_manifested(permanent)
        end

        def nothing_to_manifest
          actor.next_manifest_dread!
        end
      end

      # "Manifest dread X times, then put X +1/+1 counters on each of those creatures."
      def resolve!(value_for_x:)
        @x = value_for_x
        @remaining = value_for_x
        @manifested = []
        next_manifest_dread!
      end

      def dread_manifested(permanent)
        @manifested << permanent
        next_manifest_dread!
      end

      def next_manifest_dread!
        if @remaining.positive?
          @remaining -= 1
          ManifestChoice.perform(actor: self)
        else
          @manifested.each { |creature| add_counter("+1/+1", to: creature, amount: @x) }
        end
      end
    end
  end
end
