module Magic
  module Cards
    TheBindingOfTheTitans = Saga("The Binding of the Titans") do
      cost generic: 1, green: 1
    end

    class TheBindingOfTheTitans < Saga
      class Chapter1 < Saga::ChapterAbility
        def resolve!
          actor.game.players.each { |player| player.mill(3) }
        end
      end

      class Chapter2 < Saga::ChapterAbility
        class GraveyardChoice < Magic::Choice
          attr_reader :choices

          def initialize(actor:)
            @choices = actor.game.graveyard_cards
            super
          end

          def resolve!(targets:)
            targets.first(2).each do |target|
              target.exile!
              actor.controller.gain_life(1) if target.creature?
            end
          end
        end

        def resolve!
          actor.game.add_choice(GraveyardChoice.new(actor: actor))
        end
      end

      class Chapter3 < Saga::ChapterAbility
        class ReturnChoice < Magic::Choice
          attr_reader :choices

          def initialize(actor:)
            @choices = actor.controller.graveyard.cards.by_any_type(T::Creature, T::Land)
            super
          end

          def resolve!(target:)
            target.move_to_hand!
          end
        end

        def resolve!
          choice = ReturnChoice.new(actor: actor)
          actor.game.add_choice(choice) if choice.choices.any?
        end
      end

      def chapters
        [Chapter1, Chapter2, Chapter3]
      end
    end
  end
end