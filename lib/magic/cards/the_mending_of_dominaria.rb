module Magic
  module Cards
    TheMendingOfDominaria = Saga("The Mending of Dominaria") do
      cost generic: 3, green: 2
    end

    class TheMendingOfDominaria < Saga
      class ReturnCreatureChoice < Magic::Choice
        attr_reader :choices

        def initialize(actor:)
          @choices = actor.controller.graveyard.cards.by_any_type(T::Creature)
          super
        end

        def resolve!(target:)
          target.move_to_hand!
        end
      end

      class Chapter < Saga::ChapterAbility
        def resolve!
          actor.controller.mill(2)
          choices = ReturnCreatureChoice.new(actor: actor)
          actor.game.add_choice(choices) if choices.choices.any?
        end
      end

      class Chapter3 < Saga::ChapterAbility
        def resolve!
          lands = actor.controller.graveyard.cards.lands.to_a
          lands.each(&:resolve!)

          actor.controller.graveyard.cards.to_a.each do |card|
            card.move_zone!(to: actor.controller.library)
          end
          actor.controller.shuffle!
        end
      end

      def chapters
        [Chapter, Chapter, Chapter3]
      end
    end
  end
end