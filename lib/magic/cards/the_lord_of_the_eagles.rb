module Magic
  module Cards
    TheLordOfTheEagles = Creature("The Lord of the Eagles") do
      cost "{7}{U}{U}"
      legendary_creature_type "Bird Noble"
      keywords :flash, :flying
      power 8
      toughness 8
    end

    class TheLordOfTheEagles < Creature
      # "This spell costs {X} less to cast, where X is the total power of creatures you control with flying."
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { -player.creatures.select { _1.has_keyword?(Keywords::FLYING) }.sum(&:power) } }
      end
    end
  end
end
