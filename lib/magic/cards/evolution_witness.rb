module Magic
  module Cards
    EvolutionWitness = Creature("Evolution Witness") do
      cost generic: 2, green: 1
      creature_type "Elf Shaman Mutant"
      power 2
      toughness 1
    end

    class EvolutionWitness < Creature
      # "{1}{G}: Adapt 2." (If it has no +1/+1 counters on it, put two +1/+1 counters on it.)
      class AdaptAbility < Magic::ActivatedAbility
        costs "{1}{G}"

        def resolve!
          return if source.counters.of_type(Counters::Plus1Plus1).any?

          add_counter("+1/+1", to: source, amount: 2)
        end
      end

      class ReturnChoice < Magic::Choice::Targeted
        def choices = controller.graveyard.cards.permanents

        def choice_amount = 1

        def resolve!(target:)
          raise ArgumentError, "#{target.name} is not a valid choice" unless choices.include?(target)

          move_card(target, from: controller.graveyard, to: controller.hand)
        end
      end

      # "Whenever one or more +1/+1 counters are put on this creature, return target permanent card from your graveyard to
      # your hand."
      class CountersTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor && Counters[event.counter_type] == Counters::Plus1Plus1
        end

        def call
          choice = ReturnChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def activated_abilities = [AdaptAbility]
      def event_handlers = { Events::CounterAddedToPermanent => CountersTrigger }
    end
  end
end
