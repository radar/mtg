module Magic
  module Cards
    LikenessOfTheSeeker = Creature("Likeness of the Seeker") do
      enchantment_creature_type "Human Monk"
      cost generic: 1, green: 1
      power 3
      toughness 3
    end

    class LikenessOfTheSeeker < Creature
      # The combat layer does not currently emit a blocker-declared event.
    end
  end
end