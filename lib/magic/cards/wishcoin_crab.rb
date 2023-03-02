module Magic
  module Cards
    WishcoinCrab = Creature("Wishcoin Crab") do
      cost generic: 3, blue: 1
      creature_type("Crab")
      power 2
      toughness 5
    end
  end
end