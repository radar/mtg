module Magic
  module Cards
    VampireNighthawk = Creature("Vampire Nighthawk") do
      cost generic: 1, black: 2
      creature_type("Vampire Shaman")
      keywords :flying, :deathtouch, :lifelink
      power 2
      toughness 3
    end
  end
end
