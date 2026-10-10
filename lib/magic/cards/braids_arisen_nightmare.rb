module Magic
  module Cards
    BraidsArisenNightmare = Creature("Braids, Arisen Nightmare") do
      legendary_creature_type "Nightmare"
      cost generic: 1, black: 2
      power 3
      toughness 3
    end

    class BraidsArisenNightmare < Creature
      class EndStepChoice < Magic::Choice::May
        def prompt = "Sacrifice a permanent? Each opponent may sacrifice one that shares a card type, or lose 2 life and you draw a card."

        def choices
          controller.permanents
        end

        def resolve!(target:)
          target.sacrifice!
          game.opponents(controller).each { |opponent| resolve_opponent_choice(opponent, target.types) }
        end

        private

        def resolve_opponent_choice(opponent, types)
          choices = opponent.permanents.select { |permanent| permanent.any_type?(*types) }
          if choices.empty?
            opponent.lose_life(2)
            controller.draw!
          else
            game.add_choice(OpponentChoice.new(actor: actor, opponent: opponent, choices: choices))
          end
        end
      end

      class OpponentChoice < Magic::Choice::May
        attr_reader :choices

        def initialize(actor:, opponent:, choices:)
          @opponent = opponent
          @choices = choices
          super(actor: actor)
        end

        def prompt = "Sacrifice a permanent that shares a card type with the one Braids' controller sacrificed? If you don't, you lose 2 life and they draw a card."

        # The opponent decides, so the choice is theirs, not Braids' controller's.
        def chooser = @opponent

        # The opponent picks which of their own permanents to sacrifice; nothing is targeted.
        def targets? = false

        def resolve!(target:)
          target.sacrifice!
        end

        def decline!
          @opponent.lose_life(2)
          actor.controller.draw!
        end
      end

      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step?
        end

        def call
          game.add_choice(EndStepChoice.new(actor: actor)) if controller.permanents.any?
        end
      end

      def event_handlers
        { Events::BeginningOfEndStep => EndStepTrigger }
      end
    end
  end
end