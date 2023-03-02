module Magic
  module Cards
    TravelingPhilosopher = Creature("Traveling Philosopher") do
      cost generic: 1, white: 1
      creature_type("Human Advisor")
      power 2
      toughness 2
    end
  end
end