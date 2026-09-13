module Magic
  module Cards
    Ephemerate = Instant("Ephemerate") do
      cost white: 1
      rebound
    end

    class Ephemerate < Instant
      attr_accessor :rebound_triggered

      def single_target?
        true
      end

      def target_choices
        battlefield.creatures.controlled_by(controller)
      end

      def resolve!(target:)
        owner = target.owner
        creature_card = target.card
        target.exile!
        Permanent.resolve(game: game, card: creature_card, owner: owner, cast: false)
      end

      class ReboundCastChoice < Magic::Choice::Targeted
        def choice_amount = 1

        def choices
          actor.target_choices
        end

        def resolve!(target:)
          action = controller.prepare_cast(card: actor)
          action.mana_cost = {}
          action.targeting(target)
          game.take_action(action)
        end
      end

      class ReboundChoice < Magic::Choice::May
        def resolve!
          game.choices.add(ReboundCastChoice.new(actor: actor))
        end
      end

      class ReboundTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def should_perform?
          super && !actor.rebound_triggered
        end

        def call
          actor.rebound_triggered = true
          choice = ReboundCastChoice.new(actor: actor)
          game.choices.add(ReboundChoice.new(actor: actor)) if choice.choices.any?
        end
      end

      def event_handlers
        { Events::BeginningOfUpkeep => ReboundTrigger }
      end
    end
  end
end
