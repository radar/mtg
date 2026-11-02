module Magic
  module Cards
    MauhrUrukHaiCaptain = Creature("Mauhúr, Uruk-hai Captain") do
      cost black: 1, red: 1
      legendary_creature_type "Orc Soldier"
      power 2
      toughness 2
      keywords :menace
    end

    class MauhrUrukHaiCaptain < Creature
      # "If one or more +1/+1 counters would be put on an Army, Goblin, or Orc you control, that many plus one +1/+1
      # counters are put on it instead."
      class ExtraCounter < ReplacementEffect::CounterAmountChange
        def self.matchers = [Effects::AddCounterToPermanent]

        def applies?(effect)
          target = effect.target
          Counters[effect.counter_type] == Counters::Plus1Plus1 && effect.amount.positive? &&
            target.controller == receiver.controller &&
            %w[Army Goblin Orc].any? { target.type?(_1) }
        end

        private

        def new_amount(amount) = amount + 1
      end

      def replacement_effects = ExtraCounter.registrations
    end
  end
end
