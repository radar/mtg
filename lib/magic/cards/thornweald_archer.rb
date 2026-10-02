module Magic
  module Cards
    ThornwealdArcher = Creature("Thornweald Archer") do
      cost generic: 1, green: 1
      creature_type("Elf Archer")
      keywords :reach, :deathtouch
      power 2
      toughness 1
    end
  end
end
