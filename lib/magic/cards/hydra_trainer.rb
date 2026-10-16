module Magic
  module Cards
    HydraTrainer = Creature("Hydra Trainer") do
      cost generic: 1, green: 1
      creature_type "Human Warrior"
      power 1
      toughness 1
    end

    class HydraTrainer < Creature
      # "You may exert this creature as it attacks."
      class ExertTrigger < TriggeredAbility
        def should_perform?
          event.attack.attacker == actor
        end

        def call
          game.choices.add(ExertChoice.new(actor: actor))
        end
      end

      # "When you do, target creature gets +X/+X until end of turn, where X is the number of counters on permanents you
      # control."
      class ExertChoice < Magic::Choice::May
        def prompt = "Exert Hydra Trainer?"

        def resolve!
          actor.cannot_untap_next_turn!
          game.choices.add(PumpChoice.new(actor: actor))
        end
      end

      class PumpChoice < Magic::Choice::Targeted
        def prompt = "Choose a target creature to get +X/+X."
        def choices = game.battlefield.creatures
        def choice_amount = 1

        def resolve!(target:)
          x = controller.permanents.sum { _1.counters.count }
          pump(target, x, x)
        end
      end

      # "{2}{G}: Adapt 2."
      class AdaptAbility < Magic::ActivatedAbility
        costs "{2}{G}"

        def resolve!
          return if source.counters.of_type(Counters::Plus1Plus1).any?

          add_counter("+1/+1", to: source, amount: 2)
        end
      end

      def activated_abilities = [AdaptAbility]
      def event_handlers = super.merge({ Events::AttackDeclared => ExertTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
