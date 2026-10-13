module Magic
  module Cards
    FriendlyTeddy = Creature("Friendly Teddy") do
      cost generic: 2
      artifact_creature_type("Bear Toy")
      power 2
      toughness 2
    end

    class FriendlyTeddy < Creature
      class DiesTrigger < TriggeredAbility::Death
        def call
          game.players.each { draw_card(player: _1) }
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
