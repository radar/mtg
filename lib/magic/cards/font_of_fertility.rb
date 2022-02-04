module Magic
  module Cards
    FontOfFertility = Card("Font of Fertility") do
      type "Enchantment"
      cost green: 1
    end

    class FontOfFertility < Card
      def activated_abilities
        [
          ActivatedAbility.new(
            costs: [Costs::Mana.new(generic: 1, green: 1)],
            ability: -> {
              destroy!
              game.add_effect(
                Effects::SearchLibraryBasicLandEntersTapped.new(
                  library: controller.library,
                )
              )
            }
          )
        ]
      end
    end
  end
end
