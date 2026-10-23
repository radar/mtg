module Magic
  module Cards
    UndeadSprinter = Creature("Undead Sprinter") do
      cost black: 1, red: 1
      creature_type "Zombie"
      keywords :trample, :haste
      power 2
      toughness 2
    end

    class UndeadSprinter < Creature
      # "You may cast this card from your graveyard if a non-Zombie creature died this turn."
      def may_cast_from_graveyard?
        return false unless zone&.graveyard?

        creature_died_this_turn?(except_type: "Zombie")
      end

      # "If you do, this creature enters with a +1/+1 counter on it."
      def entering_counters_if_cast_from_graveyard = { "+1/+1" => 1 }
    end
  end
end
