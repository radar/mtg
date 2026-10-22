module Magic
  module Cards
    SmeltedChargebug = Creature("Smelted Chargebug") do
      type T::Artifact, T::Creature, "Insect"
      cost generic: 1, red: 1
      power 1
      toughness 3
      keywords :menace
    end

    class SmeltedChargebug < Creature
      # When this creature enters, you get {E}{E}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 2
        end
      end

      # Another target attacking creature gets +1/+0 and gains menace until end of turn.
      class TargetChoice < Magic::Choice::Targeted
        def choices = attacking_creatures.reject { _1 == actor }

        def choice_amount = 1

        def resolve!(target:)
          pump(target, 1, 0)
          give_keyword(target, :menace)
        end
      end

      class PayChoice < Magic::Choice::PayEnergy
        def resolve!
          super
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # Whenever this creature attacks, you may pay {E}. If you do, another target attacking creature gets +1/+0 and
      # gains menace until end of turn.
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attack.attacker == actor
        end

        def call
          choice = PayChoice.new(actor: actor)
          game.add_choice(choice) if choice.can_pay? && TargetChoice.new(actor: actor).choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = super.merge({ Events::AttackDeclared => AttackTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
