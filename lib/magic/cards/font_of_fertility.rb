module Magic
  module Cards
    FontOfFertility = Enchantment("Font of Fertility") do
      type "Enchantment"
      cost green: 1
    end

    class FontOfFertility < Enchantment
      class ActivatedAbility < Magic::ActivatedAbility
        def costs = [Costs::Mana.new(green: 1), Costs::Sacrifice.new(source)]

        def resolve!
          effect = Effects::SearchLibraryForBasicLand.new(
            source: source,
            enters_tapped: true,
          )
          game.add_effect(effect)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
