module Magic
  module Cards
    ReluctantRoleModel = Creature("Reluctant Role Model") do
      cost generic: 1, white: 1
      creature_type "Human Survivor"
      power 2
      toughness 2
    end

    class ReluctantRoleModel < Creature
      # "Survival -- At the beginning of your second main phase, if this creature is tapped, put a flying, lifelink, or
      # +1/+1 counter on it."
      class CounterChoice < Magic::Choice
        COUNTERS = {
          flying: Counters::Flying,
          lifelink: Counters::Lifelink,
          plus_one: Counters::Plus1Plus1
        }.freeze

        def modes = { flying: "Flying counter", lifelink: "Lifelink counter", plus_one: "+1/+1 counter" }

        def resolve!(mode:)
          counter = COUNTERS.fetch(mode) { raise ArgumentError, "unknown counter #{mode.inspect}" }
          trigger_effect(:add_counter, source: actor, target: actor, counter_type: counter)
        end
      end

      class SurvivalTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && actor.tapped?
        end

        def call
          game.choices.add(CounterChoice.new(actor: actor))
        end
      end

      # "Whenever this creature or another creature you control dies, if it had counters on it, put those counters on up
      # to one target creature."
      class MoveCountersChoice < Magic::Choice::Targeted
        def initialize(actor:, counters:)
          @counters = counters
          super(actor: actor)
        end

        def choices = battlefield.creatures

        def choice_amount = 0..1

        def resolve!(target:)
          @counters.map(&:class).tally.each do |counter_type, amount|
            trigger_effect(:add_counter, source: actor, target: target, counter_type: counter_type, amount: amount)
          end
        end

        def decline! = nil
      end

      module MovesCounters
        def call
          counters = event.permanent.counters.to_a
          choice = MoveCountersChoice.new(actor: actor, counters: counters)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class DiesTrigger < TriggeredAbility::Death
        include MovesCounters

        def should_perform? = event.permanent.counters.any?
      end

      class OtherDiesTrigger < TriggeredAbility
        include MovesCounters

        def should_perform?
          event.permanent != actor && event.permanent.controller == controller && event.permanent.counters.any?
        end
      end

      def death_triggers = [DiesTrigger]

      def event_handlers
        { Events::SecondMainPhase => SurvivalTrigger, Events::CreatureDied => OtherDiesTrigger }
      end
    end
  end
end
