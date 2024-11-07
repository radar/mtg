module Magic
  module Cards
    GloriousAnthem = Enchantment("Glorious Anthem") do
      type "Enchantment"
      cost generic: 1, white: 2
    end

    class GloriousAnthem < Enchantment
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1

        applicable_targets { your.creatures }
      end

      def static_abilities = [PowerAndToughnessModification]
    end
  end
end
