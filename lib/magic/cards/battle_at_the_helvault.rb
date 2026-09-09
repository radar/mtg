module Magic
  module Cards
    BattleAtTheHelvault = Saga("Battle at the Helvault") do
      cost generic: 4, white: 2
    end

    class BattleAtTheHelvault < Saga
      AvacynToken = Token.create("Avacyn") do
        legendary_creature_type "Angel"
        power 8
        toughness 8
        colors :white
        keywords :flying, :vigilance, :indestructible
      end

      class Chapter1 < Saga::ChapterAbility
        def resolve!
          actor.game.opponents(actor.controller).each do |opponent|
            opponent.permanents.nonland.each do |permanent|
              permanent.exile!
            end
          end
        end
      end

      class Chapter3 < Saga::ChapterAbility
        def resolve!
          actor.create_token(token_class: AvacynToken)
        end
      end

      def chapters
        [Chapter1, Chapter1, Chapter3]
      end
    end
  end
end