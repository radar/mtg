module Magic
  module Cards
    SwiftbladeVindicator = Creature("Swiftblade Vindicator") do
      cost red: 1, white: 1
      creature_type("Human Soldier")
      keywords :double_strike, :vigilance, :trample
      power 1
      toughness 1
    end
  end
end
