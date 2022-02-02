module Magic
  module Cards
    FalconerAdept = Creature("Falconer Adept") do
      cost generic: 3, white: 1
      type "Creature -- Human Soldier"
      power 2
      toughness 3
    end

    class FalconerAdept < Creature
      def receive_notification(event)
        case event
        when Events::AttackersDeclared
          game.current_turn.add_attacking_token(Tokens::Bird) if event.attackers.include?(self)
        end
      end
    end
  end
end
