module Magic
  module Cards
    Fountainport = Card("Fountainport") do
      type T::Land
    end

    class Fountainport < Card
      class ColorlessMana < Magic::TapManaAbility
        choices :colorless
      end

      # {2}, {T}, Sacrifice a token: Draw a card.
      class DrawAbility < Magic::ActivatedAbility
        costs "{2}, {T}, Sacrifice a token"

        def resolve!
          draw_card
        end
      end

      # {3}, {T}, Pay 1 life: Create a 1/1 blue Fish creature token.
      class FishAbility < Magic::ActivatedAbility
        costs "{3}, {T}, Pay 1 life"

        def resolve!
          trigger_effect(:create_token, token_class: Tokens::Fish)
        end
      end

      # {4}, {T}: Create a Treasure token.
      class TreasureAbility < Magic::ActivatedAbility
        costs "{4}, {T}"

        def resolve!
          create_token(token: Tokens::Treasure)
        end
      end

      def activated_abilities = [ColorlessMana, DrawAbility, FishAbility, TreasureAbility]
    end
  end
end
