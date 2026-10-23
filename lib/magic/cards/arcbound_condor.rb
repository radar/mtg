module Magic
  module Cards
    ArcboundCondor = Creature("Arcbound Condor") do
      cost generic: 2, black: 2
      artifact_creature_type "Bird"
      keywords :flying
      power 0
      toughness 0
    end

    class ArcboundCondor < Creature
      # "Modular 3 (This creature enters with three +1/+1 counters on it.)"
      class EntryCounters < Abilities::Static::AdditionalCountersForEntering
        def additional_counters_for_entering(permanent)
          permanent == source ? 3 : 0
        end
      end

      def static_abilities = [EntryCounters]

      # "Whenever another artifact you control enters, target creature an opponent controls gets -1/-1 until end of turn."
      class ArtifactEntersTrigger < TriggeredAbility::EnterTheBattlefield
        class ShrinkChoice < Magic::Choice::Targeted
          def choices = game.opponents(controller).flat_map { _1.creatures.to_a }

          def choice_amount = 1

          def resolve!(target:)
            pump(target, -1, -1)
          end
        end

        def should_perform?
          under_your_control? && event.permanent.artifact? && event.permanent != actor
        end

        def call
          choice = ShrinkChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "Modular: When it dies, you may put its +1/+1 counters on target artifact creature."
      class DiesTrigger < TriggeredAbility::Death
        class MoveCounters < Magic::Choice::Targeted
          def initialize(actor:, amount:)
            @amount = amount
            super(actor: actor)
          end

          def choices = battlefield.controlled_by(controller).creatures.select(&:artifact?)

          def choice_amount = 1

          def resolve!(target:)
            target.add_counter("+1/+1", amount: @amount)
          end
        end

        def call
          amount = actor.counters.count
          return if amount.zero?

          choice = MoveCounters.new(actor: actor, amount: amount)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def death_triggers = [DiesTrigger]

      def event_handlers = super.merge(Events::EnteredTheBattlefield => ArtifactEntersTrigger) { |_, old, new| [*old, *new] }
    end
  end
end
