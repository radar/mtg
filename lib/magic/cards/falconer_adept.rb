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
          if event.attacks.any? { |attack| attack.attacker == self }
            token = Tokens::Bird.new(game: game, controller: controller)
            token.play!
            token.tap!

            game.current_turn.declare_attacker(token)
          end
        end
      end
    end
  end
end
