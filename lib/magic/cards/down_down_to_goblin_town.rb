module Magic
  module Cards
    DownDownToGoblinTown = Saga("Down, Down to Goblin-town") do
      cost generic: 2, black: 1
    end

    class DownDownToGoblinTown < Saga
      class Chapter1 < Saga::ChapterAbility
        class TargetChoice < Magic::Choice::Targeted
          def choices = game.opponents(controller)

          def choice_amount = 1

          def resolve!(target:)
            game.notify!(Events::CardsRevealed.new(player: target, cards: target.hand.cards.to_a))
            choice = Magic::Choice::DiscardFromRevealedHand.new(actor: actor, player: target, excluded_types: ["Land"])
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def resolve!
          game.add_choice(TargetChoice.new(actor: actor))
        end
      end

      class Chapter2 < Saga::ChapterAbility
        def resolve!
          Magic::Amass.call(source: actor, controller: actor.controller, amount: 1)
        end
      end

      class Chapter3 < Saga::ChapterAbility
        class TargetChoice < Magic::Choice::Targeted
          def choices = game.opponents(controller)

          def choice_amount = 1

          def resolve!(target:)
            target.trigger_effect(:lose_life, source: actor, life: 1)
            actor.trigger_effect(:gain_life, life: 1)
          end
        end

        def resolve!
          game.add_choice(TargetChoice.new(actor: actor))
        end
      end

      class Chapter4 < Chapter3
      end

      def chapters = [Chapter1, Chapter2, Chapter3, Chapter4]
    end
  end
end
