module Magic
  module Cards
    FontOfFertility = Enchantment("Font of Fertility") do
      type "Enchantment"
      cost green: 1
    end


    class FontOfFertility < Enchantment
      class ActivatedAbility < Magic::ActivatedAbility

        def initialize(source:)
          @costs = [Costs::Mana.new(green: 1), Costs::Sacrifice.new(source)]
          super
        end

        def resolve!
          game.add_effect(
            Effects::SearchLibraryBasicLandEntersTapped.new(source: source, controller: source.controller)
          )
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
