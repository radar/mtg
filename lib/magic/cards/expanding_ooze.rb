module Magic
  module Cards
    ExpandingOoze = Creature("Expanding Ooze") do
      cost "{1}{B}{G}"
      creature_type "Ooze"
      power 3
      toughness 3
    end

    class ExpandingOoze < Creature
      # "{B}{G}: Adapt 1." (If it has no +1/+1 counters on it, put a +1/+1 counter on it.)
      class AdaptAbility < Magic::ActivatedAbility
        costs "{B}{G}"

        def resolve!
          return if source.counters.of_type(Counters::Plus1Plus1).any?

          add_counter("+1/+1", to: source)
        end
      end

      class CounterChoice < Magic::Choice::Targeted
        def choices = controller.creatures.select(&:modified?)

        def choice_amount = 1

        def resolve!(target:)
          add_counter("+1/+1", to: target)
        end
      end

      # "Whenever this creature attacks, put a +1/+1 counter on target modified creature you control."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          choice = CounterChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def activated_abilities = [AdaptAbility]
      def event_handlers = { Events::CreatureAttacked => AttacksTrigger }
    end
  end
end
