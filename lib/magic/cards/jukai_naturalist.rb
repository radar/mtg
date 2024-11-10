module Magic
  module Cards
    JukaiNaturalist = Creature("Jukai Naturalist") do
      cost generic: 1, green: 1
      enchantment_creature_type "Human Monk"
      power 2
      toughness 2
      keywords :lifelink
    end

    class JukaiNaturalist < Creature
      class ReduceManaCost < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: -1 }
          @applies_to = -> (c) { c.enchantment? }
        end
      end

      def static_abilities
        [ReduceManaCost]
      end
    end
  end
end
