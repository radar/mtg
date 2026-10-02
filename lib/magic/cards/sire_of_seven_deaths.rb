module Magic
  module Cards
    SireOfSevenDeaths = Creature("Sire of Seven Deaths") do
      cost generic: 7
      creature_type("Eldrazi")
      keywords :reach, :first_strike, :vigilance, :menace, :trample, :lifelink
      ward life: 7
      power 7
      toughness 7
    end
  end
end
