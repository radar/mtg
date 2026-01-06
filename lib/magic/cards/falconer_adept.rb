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
        creature_type "Bird"
        power 1
        toughness 1
        colors :white
        keywords :flying
      end

      class PreliminaryAttackersDeclaredTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { |attack| attack.attacker == actor }
        end

        def call
          token = trigger_effect(:create_token, token_class: BirdToken, enters_tapped: true).first
          game.current_turn.declare_attacker(token)
        end
      end

      def event_handlers
        {
          Events::PreliminaryAttackersDeclared => PreliminaryAttackersDeclaredTrigger
        }
      end

    end
  end
end
