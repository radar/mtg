module Magic
  module Cards
    FalconerAdept = Creature("Falconer Adept") do
      cost generic: 3, white: 1
      creature_type("Human Soldier")
      power 2
      toughness 3
    end

    class FalconerAdept < Creature
      BirdToken = Token.create("Bird") do
        type "Creature — Bird"
        power 1
        toughness 1
        colors :white
        keywords :flying
      end

      def event_handlers
        {
          Events::PreliminaryAttackersDeclared => -> (receiver, event) do
            return if event.attacks.none? { |attack| attack.attacker == receiver }
            token = trigger_effect(:create_token, token_class: BirdToken, enters_tapped: true).first
            game.current_turn.declare_attacker(token)
          end
        }
      end

    end
  end
end
