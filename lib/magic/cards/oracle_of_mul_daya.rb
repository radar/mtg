module Magic
  module Cards
    OracleOfMulDaya = Creature("Oracle of Mul Daya") do
      cost generic: 3, green: 1
      creature_type "Elf Shaman"
      power 2
      toughness 2
    end

    class OracleOfMulDaya < Creature
      def additional_lands_per_turn = 1
    end
  end
end