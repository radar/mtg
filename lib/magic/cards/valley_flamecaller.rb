module Magic
  module Cards
    ValleyFlamecaller = Creature("Valley Flamecaller") do
      cost generic: 2, red: 1
      creature_type("Lizard Warlock")
      power 3
      toughness 3
    end

    class ValleyFlamecaller < Creature
      TYPES = %w[Lizard Mouse Otter Raccoon].freeze

      # If a Lizard, Mouse, Otter, or Raccoon you control would deal damage to a permanent or player, it deals
      # that much damage plus 1 instead.
      class DamageBoost < ReplacementEffect::DamageIncreaser
        def increase = 1

        private

        def source_applies?(origin)
          origin.is_a?(Magic::Permanent) && ValleyFlamecaller::TYPES.any? { origin.type?(_1) }
        end
      end

      def replacement_effects = DamageBoost.registrations
    end
  end
end
