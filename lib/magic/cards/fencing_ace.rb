module Magic
  module Cards
    FencingAce = Creature("Fencing Ace") do
      creature_type("Human Soldier")
      cost generic: 1, white: 1
      power 1
      toughness 1
      keywords :double_strike
    end
  end
end
