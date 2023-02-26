module Magic
  module Cards
    BattlefieldRaptor = Creature("Battlefield Raptor") do
      creature_type("Bird")
      cost white: 1
      power 1
      toughness 2
      keywords :flying, :first_strike
    end
  end
end
