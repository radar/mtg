module Magic
  module Cards
    FearOfBeingHunted = Creature("Fear of Being Hunted") do
      cost generic: 1, red: 2
      enchantment_creature_type "Nightmare"
      keywords :haste
      power 4
      toughness 2
    end

    class FearOfBeingHunted < Creature
      # "This creature must be blocked if able."
      def must_be_blocked? = true
    end
  end
end
