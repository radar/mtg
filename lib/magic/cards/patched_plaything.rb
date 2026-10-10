module Magic
  module Cards
    PatchedPlaything = Creature("Patched Plaything") do
      cost generic: 2, white: 1
      artifact_creature_type("Toy")
      keywords :double_strike
      power 4
      toughness 3
    end

    class PatchedPlaything < Creature
      enters_with_counters "-1/-1", 2, if_cast_from_hand: true
    end
  end
end
