module Magic
  module Cards
    GuideOfSouls = Creature("Guide of Souls") do
      cost white: 1
      creature_type "Human Cleric"
      power 1
      toughness 2
    end

    class GuideOfSouls < Creature
      # Whenever another creature you control enters, you gain 1 life and get {E}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control?
        end

        def call
          gain_life 1
          gain_energy 1
        end
      end

      # When you do, put two +1/+1 counters and a flying counter on target attacking creature. It becomes an Angel in
      # addition to its other types.
      class TargetChoice < Magic::Choice::Targeted
        def choices = attacking_creatures

        def choice_amount = 1

        # Energy is already paid and the reflexive trigger has a target, so skipping takes the first one.
        def decline!
          resolve!(target: choices.first)
        end

        def resolve!(target:)
          add_counter("+1/+1", to: target, amount: 2)
          add_counter("flying", to: target)
          target.add_types("Angel", until_eot: false)
        end
      end

      class PayChoice < Magic::Choice::PayEnergy
        def resolve!
          super
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # Whenever you attack, you may pay {E}{E}{E}. When you do, ...
      class AttackTrigger < TriggeredAbility::YouAttack
        def call
          choice = PayChoice.new(actor: actor, amount: 3)
          game.add_choice(choice) if choice.can_pay?
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => EntersTrigger).merge(AttackTrigger.handlers) { |_, old, new| [*old, *new] }
      end
    end
  end
end
