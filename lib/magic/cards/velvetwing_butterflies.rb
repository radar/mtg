module Magic
  module Cards
    VelvetwingButterflies = Creature("Velvetwing Butterflies") do
      cost generic: 2, white: 1
      creature_type "Insect"
      keywords :flying
      power 2
      toughness 2
    end

    class VelvetwingButterflies < Creature
      # Gaze in Wonder {1}{W}, Instant -- Adventure: "Tap one or two target creatures."
      adventure generic: 1, white: 1

      def adventure_instant? = true

      def target_choices = battlefield.creatures

      def adventure_resolve!(targets:, **)
        targets.uniq.first(2).each { |creature| trigger_effect(:tap, target: creature) }
      end
    end
  end
end
