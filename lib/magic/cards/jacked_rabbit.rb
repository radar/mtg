module Magic
  module Cards
    JackedRabbit = Creature("Jacked Rabbit") do
      cost x: 1, generic: 1, white: 1
      creature_type "Rabbit Warrior"
      power 1
      toughness 2
    end

    class JackedRabbit < Creature
      RabbitToken = Token.create "Rabbit" do
        creature_type "Rabbit"
        power 1
        toughness 1
        colors :white
      end

      # Ravenous: "This creature enters with X +1/+1 counters on it. If X is 5 or more, draw a card when it enters."
      def entering_counters_for_x(x) = x.positive? ? { "+1/+1" => x } : {}

      class RavenousTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor && actor.x_value.to_i >= 5
        end

        def call
          trigger_effect(:draw_card)
        end
      end

      # "Whenever this creature attacks, create a number of 1/1 white Rabbit creature tokens equal to this creature's power."
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacker == actor
        end

        def call
          trigger_effect(:create_token, token_class: RabbitToken, amount: actor.power) if actor.power.positive?
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => RavenousTrigger, Events::CreatureAttacked => AttackTrigger)
      end
    end
  end
end
