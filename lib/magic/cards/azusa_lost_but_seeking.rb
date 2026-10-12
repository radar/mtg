module Magic
  module Cards
    AzusaLostButSeeking = Creature("Azusa, Lost but Seeking") do
      cost generic: 2, green: 1
      legendary_creature_type "Human Monk"
      power 1
      toughness 2
    end

    class AzusaLostButSeeking < Creature
      # "You may play two additional lands on each of your turns."
      additional_lands_per_turn 2
    end
  end
end
