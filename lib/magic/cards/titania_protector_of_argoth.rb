module Magic
  module Cards
    TitaniaProtectorOfArgoth = Creature("Titania, Protector of Argoth") do
      cost generic: 2, green: 1
      creature_type "Elemental"
      power 5
      toughness 3
    end

    class TitaniaProtectorOfArgoth < Creature
      def additional_lands_per_turn = 1
    end
  end
end