module Magic
  module Cards
    IzzetGeneratorium = Artifact("Izzet Generatorium") do
      cost blue: 1, red: 1
    end

    class IzzetGeneratorium < Artifact
      # If you would get one or more {E}, you get that many plus one {E} instead.
      class EnergyBonus < ReplacementEffect::CounterAmountChange
        def self.matchers = [Effects::AddCounterToPlayer]

        def applies?(effect)
          Counters[effect.counter_type] == Counters::Energy && effect.amount.positive? && effect.target == receiver.controller
        end

        private

        def new_amount(amount) = amount + 1
      end

      # {T}: Draw a card. Activate only if you've paid or lost four or more {E} this turn.
      class DrawAbility < Magic::ActivatedAbility
        costs "{T}"

        def requirements_met? = game.current_turn.energy_paid_by_player(controller) >= 4

        def resolve!
          draw_card
        end
      end

      def replacement_effects = EnergyBonus.registrations

      def activated_abilities = [DrawAbility]
    end
  end
end
