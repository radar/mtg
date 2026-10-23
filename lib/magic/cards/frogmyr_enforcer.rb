module Magic
  module Cards
    FrogmyrEnforcer = Creature("Frogmyr Enforcer") do
      artifact_creature_type("Frog Myr")
      cost generic: 7
      power 4
      toughness 4
      prototype cost: { generic: 3, red: 1 }, power: 2, toughness: 2
    end

    class FrogmyrEnforcer < Creature
      # "Affinity for artifacts (This spell costs {1} less to cast for each artifact you control.)"
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { -game.battlefield.controlled_by(player).count { _1.type?("Artifact") } } }
      end
    end
  end
end
