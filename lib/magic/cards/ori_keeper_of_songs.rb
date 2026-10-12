module Magic
  module Cards
    OriKeeperOfSongs = Creature("Ori, Keeper of Songs") do
      cost generic: 2, white: 1
      legendary_creature_type "Dwarf Bard"
      power 3
      toughness 3
    end

    class OriKeeperOfSongs < Creature
      # "Storied (...)  As long as you have an enduring story, Ori gets +1/+0 and has vigilance."
      class StoriedPower < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 0
        applicable_targets { [source] }
        conditions { Magic::Storied.enduring_story?(controller) }
      end

      class StoriedVigilance < Abilities::Static::KeywordGrant
        keyword_grants Keywords::VIGILANCE
        applicable_targets { [source] }
        conditions { Magic::Storied.enduring_story?(controller) }
      end

      def static_abilities = [StoriedPower, StoriedVigilance]
    end
  end
end
