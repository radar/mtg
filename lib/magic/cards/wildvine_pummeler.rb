module Magic
  module Cards
    WildvinePummeler = Creature("Wildvine Pummeler") do
      creature_type "Giant Berserker"
      cost generic: 6, green: 1
      power 6
      toughness 5
      keywords :reach, :trample
    end

    class WildvinePummeler < Creature
      # Vivid -- This spell costs {1} less to cast for each color among permanents you control.
      def self_mana_cost_adjustment
        { generic: -> { -(controller || owner).colors_among_permanents } }
      end
    end
  end
end
