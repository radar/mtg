module Magic
  module Cards
    AzusasManyJourneys = Saga("Azusa's Many Journeys") do
      cost generic: 1, green: 1
    end

    class AzusasManyJourneys < Saga
      def back_face
        LikenessOfTheSeeker
      end

      class Chapter1 < Saga::ChapterAbility
        def resolve!
          actor.card.define_singleton_method(:additional_lands_per_turn) { 1 }
        end
      end

      class Chapter2 < Saga::ChapterAbility
        def resolve!
          actor.controller.gain_life(3)
        end
      end

      class Chapter3 < Saga::ChapterAbility
        def resolve!
          actor.transform!(
            card: LikenessOfTheSeeker.new(game: actor.game, owner: actor.controller),
          )
        end
      end

      def chapters
        [Chapter1, Chapter2, Chapter3]
      end
    end
  end
end