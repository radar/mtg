module Magic
  module Cards
    ThrivingSkyclaw = Creature("Thriving Skyclaw") do
      cost generic: 2, red: 2
      creature_type "Cat Dragon"
      power 3
      toughness 2
      keywords :flying
    end

    class ThrivingSkyclaw < Creature
      # When this creature enters, you get {E}{E}{E}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 3
        end
      end

      class PayChoice < Magic::Choice::PayEnergy
        def resolve!
          super
          add_counter("+1/+1", to: actor) if battlefield.permanents.any? { _1.equal?(actor) }
        end
      end

      # Whenever this creature attacks, you may pay {E}{E}{E}. If you do, put a +1/+1 counter on it.
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attack.attacker == actor
        end

        def call
          choice = PayChoice.new(actor: actor, amount: 3)
          game.add_choice(choice) if choice.can_pay?
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = super.merge({ Events::AttackDeclared => AttackTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
