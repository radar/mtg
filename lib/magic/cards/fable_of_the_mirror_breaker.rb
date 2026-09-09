module Magic
  module Cards
    FableOfTheMirrorBreaker = Saga("Fable of the Mirror-Breaker") do
      cost generic: 2, red: 1
    end

    class FableOfTheMirrorBreaker < Saga
      class Chapter1 < Saga::ChapterAbility
        def resolve!
          actor.create_token(token_class: GoblinShamanToken)
        end
      end

      class Chapter2 < Saga::ChapterAbility
        def resolve!
        end
      end

      class Chapter3 < Saga::ChapterAbility
        def resolve!
          actor.transform!(card: ReflectionOfKikiJiki.new(game: actor.game, owner: actor.controller))
        end
      end

      GoblinShamanToken = Token.create("Goblin Shaman") do
        creature_type "Goblin Shaman"
        power 2
        toughness 2
        colors :red
      end

      def chapters
        [Chapter1, Chapter2, Chapter3]
      end
    end

  end
end