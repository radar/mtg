module Magic
  module Cards
    SzarelGenesisShepherd = Creature("Szarel, Genesis Shepherd") do
      legendary_creature_type "Insect Druid"
      cost generic: 2, black: 1, red: 1, green: 1
      power 3
      toughness 3
      keywords :flying
    end
  end
end