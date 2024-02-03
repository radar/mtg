module Magic
  module Cards
    ShortSword = Equipment("Short Sword") do
      cost generic: 1

      equip [Costs::Mana.new(generic: 1)]

      def power_modification
        1
      end

      def toughness_modification
        1
      end
    end
  end
end
