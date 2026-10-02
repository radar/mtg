module Magic
  module Cards
    VampireInterloper = Creature("Vampire Interloper") do
      cost generic: 1, black: 1
      creature_type("Vampire Scout")
      keywords :flying
      power 2
      toughness 1
    end

    class VampireInterloper < Creature
      def can_block?(_) = false
    end
  end
end
