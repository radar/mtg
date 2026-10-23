module Magic
  module Cards
    IndebtedSpirit = Creature("Indebted Spirit") do
      enchantment_creature_type("Spirit")
      cost white: 1
      keywords :afterlife
      bestow Costs::Mana.new(generic: 2, white: 1)
      power 1
      toughness 1
    end

    class IndebtedSpirit < Creature
      # "Enchanted creature gets +1/+1 and has afterlife 1."
      def power_modification = 1

      def toughness_modification = 1

      def keyword_grants = [Keywords::AFTERLIFE]
    end
  end
end
