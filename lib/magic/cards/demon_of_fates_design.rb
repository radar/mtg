module Magic
  module Cards
    DemonOfFatesDesign = Creature("Demon of Fate's Design") do
      type T::Enchantment, T::Creature, T::Creatures["Demon"]
      cost generic: 4, black: 2
      power 6
      toughness 6
      keywords :flying, :trample
    end

    class DemonOfFatesDesign < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{B}, Sacrifice a creature"

        def resolve!
          source.modify_power(1)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end