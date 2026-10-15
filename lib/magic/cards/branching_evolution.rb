module Magic
  module Cards
    BranchingEvolution = Enchantment("Branching Evolution") do
      cost generic: 2, green: 1
    end

    class BranchingEvolution < Enchantment
      # "If one or more +1/+1 counters would be put on a creature you control, twice that many +1/+1 counters are put
      # on that creature instead."
      class CreatureCounterDoubler < ReplacementEffect::CounterAmountChange
        def self.matchers = [Effects::AddCounterToPermanent]

        def applies?(effect)
          effect.counter_type == Counters::Plus1Plus1 &&
            effect.target.creature? &&
            effect.target.controller == receiver.controller
        end

        private

        def new_amount(amount) = amount * 2
      end

      def replacement_effects = CreatureCounterDoubler.registrations
    end
  end
end
