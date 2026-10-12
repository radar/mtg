module Magic
  module Cards
    HuskbursterSwarm = Creature("Huskburster Swarm") do
      cost generic: 7, black: 1
      creature_type("Elemental Insect")
      keywords :menace, :deathtouch
      power 6
      toughness 6
    end

    class HuskbursterSwarm < Creature
      # This spell costs {1} less to cast for each creature card you own in exile and in your graveyard.
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { -(player.graveyard.count(&:creature?) + game.exile.cards.count { _1.owner == player && _1.creature? }) } }
      end
    end
  end
end
