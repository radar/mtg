module Magic
  module Cards
    RollRollRollRoll = Saga("Roll-Roll-Roll-Roll") do
      cost generic: 2, blue: 1
    end

    class RollRollRollRoll < Saga
      # "return it to the battlefield under its owner's control at the beginning of the next end step": a
      # game-level listener that removes itself once it has fired.
      class ReturnLater
        def initialize(game:, card:)
          @game = game
          @card = card
        end

        def receive_event(event)
          return unless event.is_a?(Events::BeginningOfEndStep)

          @game.unsubscribe(self)
          @card.resolve!(controller: @card.owner) if @card.zone&.exile?
        end
      end

      # I, II, III, IV -- Exile up to one target creature or land you control. If you do, return it to the
      # battlefield under its owner's control at the beginning of the next end step.
      class Chapter1 < Saga::ChapterAbility
        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).select { _1.creature? || _1.land? }

          def choice_amount = 0..1

          def resolve!(target: nil)
            return if target.nil?

            card = target.card
            trigger_effect(:exile, target: target)
            game.subscribe(ReturnLater.new(game: game, card: card)) unless target.token?
          end
        end

        def resolve!
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class Chapter2 < Chapter1
      end

      class Chapter3 < Chapter1
      end

      class Chapter4 < Chapter1
      end

      def chapters = [Chapter1, Chapter2, Chapter3, Chapter4]
    end
  end
end
