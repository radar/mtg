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
        when Events::AttackingCreature
          create_bird_token! if event.creature == self
        end
      end

      private

      def create_bird_token!
        bird = Tokens::Bird.new(game: game, controller: controller)
        bird.resolve!
        bird.tap!

        game.combat.declare_attacker(bird, target: nil)
      end
    end
  end
end
