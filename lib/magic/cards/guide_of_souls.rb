module Magic
  module Cards
    GuideOfSouls = Creature("Guide of Souls") do
      cost white: 1
      creature_type("Human Cleric")
      power 1
      toughness 2
    end

    class GuideOfSouls < Creature
      # "Whenever another creature you control enters, you gain 1 life and get {E} (an energy counter)."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          under_your_control? && another_creature?
        end

        def call
          gain_life(1, to: controller)
          gain_energy 1
        end
      end

      # "Whenever you attack, you may pay {E}{E}{E}. When you do, put two +1/+1 counters and a flying counter on
      # target attacking creature. It becomes an Angel in addition to its other types."
      class AttackTrigger < TriggeredAbility::YouAttack
        class CountersChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).attacking

          def choice_amount = 1

          def resolve!(target:)
            add_counter("+1/+1", to: target, amount: 2)
            add_counter("flying", to: target)
            target.add_types(T::Creatures["Angel"], until_eot: false)
          end
        end

        class PayChoice < Magic::Choice::PayEnergy
          def resolve!
            super
            choice = CountersChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def call
          choice = PayChoice.new(actor: actor, amount: 3)
          game.add_choice(choice) if choice.can_pay?
        end
      end

      def event_handlers = super.merge(Events::EnteredTheBattlefield => EntersTrigger).merge(AttackTrigger.handlers)
    end
  end
end
