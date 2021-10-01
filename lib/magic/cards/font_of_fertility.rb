module Magic
  module Cards
    FontOfFertility = Card("Font of Fertility") do
      type "Enchantment"
      cost green: 1
    end

    class FontOfFertility < Card
      def activated_abilities
        [
          Abilities::Activated::SacrificeAndSearchLibrary.new(self, cost: { generic: 1, green: 1})
        ]
      end
    end
  end
end
