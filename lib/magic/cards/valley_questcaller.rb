module Magic
  module Cards
    ValleyQuestcaller = Creature("Valley Questcaller") do
      cost generic: 1, white: 1
      creature_type("Rabbit Warrior")
      power 2
      toughness 3
    end

    class ValleyQuestcaller < Creature
      TYPES = %w[Rabbit Bat Bird Mouse].freeze

      # Whenever one or more other Rabbits, Bats, Birds, and/or Mice you control enter, scry 1.
      class TribeEnters < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          under_your_control? && event.permanent != actor && ValleyQuestcaller::TYPES.any? { event.permanent.type?(_1) }
        end

        def call
          game.choices.add(Magic::Choice::Scry.new(actor: actor, amount: 1))
        end
      end

      def event_handlers = super.merge(Events::EnteredTheBattlefield => TribeEnters)

      # Other Rabbits, Bats, Birds, and Mice you control get +1/+1.
      class TribeBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1

        def applicable_targets
          (source.controller.creatures - [source]).select { |creature| ValleyQuestcaller::TYPES.any? { creature.type?(_1) } }
        end
      end

      def static_abilities = [TribeBuff]
    end
  end
end
