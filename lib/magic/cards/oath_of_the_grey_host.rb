module Magic
  module Cards
    OathOfTheGreyHost = Saga("Oath of the Grey Host") do
      cost generic: 3, black: 1
    end

    class OathOfTheGreyHost < Saga
      SpiritToken = Token.create("Spirit") do
        creature_type "Spirit"
        power 1
        toughness 1
        colors :white
        keywords :flying
      end

      # "I -- You and target opponent each create a Food token."
      class Chapter1 < Saga::ChapterAbility
        class OpponentChoice < Magic::Choice::Targeted
          def prompt = "Target opponent creates a Food token."

          def choices = game.opponents(controller)

          def choice_amount = 1

          def resolve!(target:)
            create_token(token: Tokens::Food, controller: target)
          end
        end

        def resolve!
          create_token(token: Tokens::Food)
          game.add_choice(OpponentChoice.new(actor: actor))
        end
      end

      # "II -- Each opponent loses 3 life. Create a Treasure token."
      class Chapter2 < Saga::ChapterAbility
        def resolve!
          game.opponents(actor.controller).each { lose_life(_1, 3) }
          create_token(token: Tokens::Treasure)
        end
      end

      # "III -- Create three tapped 1/1 white Spirit creature tokens with flying."
      class Chapter3 < Saga::ChapterAbility
        def resolve!
          create_token(token: SpiritToken, amount: 3, enters_tapped: true)
        end
      end

      def chapters = [Chapter1, Chapter2, Chapter3]
    end
  end
end
