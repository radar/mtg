module Magic
  module Cards
    DiregrafGhoul = Creature("Diregraf Ghoul") do
      cost black: 1
      creature_type("Zombie")
      power 2
      toughness 2
    end

    class DiregrafGhoul < Creature
      enters_tapped
    end
  end
end
