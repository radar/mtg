module Magic
  module Cards
    ByrkeLongEarOfTheLaw = Creature("Byrke, Long Ear of the Law") do
      legendary_creature_type "Rabbit Soldier"
      cost generic: 4, green: 1, white: 1
      keywords :vigilance
      power 4
      toughness 4
    end

    class ByrkeLongEarOfTheLaw < Creature
      # When Byrke enters, put a +1/+1 counter on each of up to two target creatures.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class CounterChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures

          def choice_amount = 0..2

          def resolve!(targets:)
            Array(targets).first(2).each { add_counter("+1/+1", to: _1) }
          end
        end

        def call
          game.add_choice(CounterChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]

      # Whenever a creature you control with a +1/+1 counter on it attacks, double the number of +1/+1 counters on it.
      class AttackTrigger < TriggeredAbility
        def call
          event.attacks.map(&:attacker).select { |creature| creature.controller == controller }.each do |creature|
            count = creature.counters.of_type(Counters::Plus1Plus1).count
            add_counter("+1/+1", to: creature, amount: count) if count.positive?
          end
        end

        def should_perform? = event.active_player == controller && event.attacks.any?
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttackTrigger)
    end
  end
end
