module Magic
  module Cards
    GiganticBigBear = Creature("Gigantic Big Bear") do
      cost generic: 5, green: 2
      creature_type("Bear")
      cant_be_countered
      keywords :hexproof, :haste
      power 10
      toughness 7
    end
  end
end
