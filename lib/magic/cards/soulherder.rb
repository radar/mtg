module Magic
  module Cards
    Soulherder = Creature("Soulherder") do
      creature_type "Spirit"
      cost generic: 1, white: 1, blue: 1
      power 1
      toughness 1
    end

    class Soulherder < Creature
      class CreatureExiledTrigger < TriggeredAbility
        def should_perform?
          event.permanent.creature? && event.to.exile?
        end

        def call
          actor.add_counter("+1/+1")
        end
      end

      class BlinkChoice < Magic::Choice::Targeted
        def choices = other_creatures_you_control
        def choice_amount = 1

        def resolve!(target:)
          owner = target.owner
          creature_card = target.card
          target.exile!
          Permanent.resolve(game: game, card: creature_card, owner: owner, cast: false)
        end
      end

      class MayBlinkChoice < Magic::Choice::May
        def resolve!
          game.choices.add(BlinkChoice.new(actor: actor))
        end
      end

      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && other_creatures_you_control.any?
        end

        def call
          game.choices.add(MayBlinkChoice.new(actor: actor))
        end
      end

      def event_handlers
        {
          Events::LeftTheBattlefield => CreatureExiledTrigger,
          Events::BeginningOfEndStep => EndStepTrigger
        }
      end
    end
  end
end
