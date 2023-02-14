module Magic
  module Cards
    FalconerAdept = Creature("Falconer Adept") do
      cost generic: 3, white: 1
      creature_type("Human Soldier")
      power 2
      toughness 3
    end

    class FalconerAdept < Creature
      def event_handlers
        {
          Events::PreliminaryAttackersDeclared => -> (receiver, event) do
            return if event.attacks.none? { |attack| attack.attacker == receiver }
            token = Permanent.resolve(game: game, owner: receiver.controller, card: Tokens::Bird.new, enters_tapped: true)
            game.current_turn.declare_attacker(token)
          end
        }
      end

    end
  end
end
