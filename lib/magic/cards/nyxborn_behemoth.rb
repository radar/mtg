module Magic
  module Cards
    NyxbornBehemoth = Creature("Nyxborn Behemoth") do
      enchantment_creature_type "Beast"
      cost generic: 10, green: 2
      power 10
      toughness 10
      keywords :trample
    end

    class NyxbornBehemoth < Creature
      class ReduceManaCost < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: -> { -source.controller.permanents.enchantments.reject(&:creature?).sum(&:mana_value) } }
          @applies_to = ->(card) { card == source.card }
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{G}, Sacrifice a creature"

        def resolve!
          source.grant_indestructible!
        end
      end

      def static_abilities = [ReduceManaCost]
      def activated_abilities = [ActivatedAbility]
    end
  end
end