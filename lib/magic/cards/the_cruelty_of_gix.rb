module Magic
  module Cards
    TheCrueltyOfGix = Saga("The Cruelty of Gix") do
      cost generic: 3, black: 2
    end

    class TheCrueltyOfGix < Saga
      class Chapter1 < Saga::ChapterAbility
        class DiscardChoice < Magic::Choice
          attr_reader :choices

          def initialize(actor:)
            @choices = actor.game.opponents(actor.controller).flat_map { |player| player.hand.cards }
              .select { |card| card.creature? || card.planeswalker? }
            super
          end

          def resolve!(target:)
            target.discard!
          end
        end

        def resolve!
          actor.game.add_choice(DiscardChoice.new(actor: actor)) if actor.game.opponents(actor.controller).any? { |player| player.hand.cards.any? { |card| card.creature? || card.planeswalker? } }
        end
      end

      class Chapter2 < Saga::ChapterAbility
        class SearchChoice < Magic::Choice
          attr_reader :choices

          def initialize(actor:)
            @choices = actor.controller.library.cards
            super
          end

          def resolve!(target:)
            target.move_to_hand!
            controller.shuffle!
            controller.lose_life(3)
          end
        end

        def resolve!
          actor.game.add_choice(SearchChoice.new(actor: actor))
        end
      end

      class Chapter3 < Saga::ChapterAbility
        class GraveyardChoice < Magic::Choice
          attr_reader :choices

          def initialize(actor:)
            @choices = actor.game.graveyard_cards.by_any_type(T::Creature, T::Planeswalker)
            super
          end

          def resolve!(target:)
            target.resolve!
          end
        end

        def resolve!
          actor.game.add_choice(GraveyardChoice.new(actor: actor)) if actor.game.graveyard_cards.by_any_type(T::Creature, T::Planeswalker).any?
        end
      end

      def chapters
        [Chapter1, Chapter2, Chapter3]
      end
    end
  end
end