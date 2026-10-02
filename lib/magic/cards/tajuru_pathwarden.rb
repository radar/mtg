module Magic
  module Cards
    TajuruPathwarden = Creature("Tajuru Pathwarden") do
      cost generic: 4, green: 1
      creature_type("Elf Warrior Ally")
      keywords :vigilance, :trample
      power 5
      toughness 4
    end
  end
end
