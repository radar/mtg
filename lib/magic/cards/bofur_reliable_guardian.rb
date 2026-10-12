module Magic
  module Cards
    BofurReliableGuardian = Creature("Bofur, Reliable Guardian") do
      cost white: 1
      legendary_creature_type("Dwarf Scout")
      keywords :lifelink
      power 1
      toughness 1
    end

    class BofurReliableGuardian < Creature
      # Concerted Care {1}{W}, Instant -- Adventure: "Target artifact or creature you control gains hexproof and
      # indestructible until end of turn."
      adventure generic: 1, white: 1

      def adventure_instant? = true

      def target_choices
        (controller || owner).permanents.select { _1.type?("Artifact") || _1.creature? }
      end

      def adventure_resolve!(target:, **)
        trigger_effect(:grant_keyword, target: target, keyword: :hexproof)
        trigger_effect(:grant_keyword, target: target, keyword: :indestructible)
      end
    end
  end
end
