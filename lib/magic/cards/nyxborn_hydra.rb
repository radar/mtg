module Magic
  module Cards
    NyxbornHydra = Creature("Nyxborn Hydra") do
      enchantment_creature_type("Hydra")
      cost x: 1, green: 1
      bestow Costs::Mana.new(x: 1, green: 2)
      keywords :reach, :trample
      power 0
      toughness 1
    end

    class NyxbornHydra < Creature
      # "This permanent enters with X +1/+1 counters on it."
      def entering_counters_for_x(x) = x.positive? ? { "+1/+1" => x } : {}

      # "Enchanted creature gets +1/+1 for each +1/+1 counter on this Aura and has reach and trample."
      def enchanted_bonus_per_plus_one_counter = 1

      def keyword_grants = [Keywords::REACH, Keywords::TRAMPLE]
    end
  end
end
