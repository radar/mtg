module Magic
  module Cards
    BomburGentleDreamer = Creature("Bombur, Gentle Dreamer") do
      legendary_creature_type "Dwarf Bard"
      cost generic: 2, red: 1
      power 5
      toughness 3
    end

    class BomburGentleDreamer < Creature
      # "Storied (...) Bombur doesn't untap during your untap step unless you have an enduring story."
      def skips_untap_step?(permanent) = !Magic::Storied.enduring_story?(permanent.controller)
    end
  end
end
