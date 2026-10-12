module Magic
  module Cards
    LargeBear = Creature("Large Bear") do
      cost generic: 3, black_or_green: 2
      creature_type("Bear")
      keywords :reach, :trample, :haste
      power 5
      toughness 5
    end
  end
end
