module Magic
  module Cards
    Opt = Instant("Opt") do
      cost blue: 1
    end

    class Opt < Instant
      class ScryChoice < Magic::Choice::Scry
        def resolve!(**args)
          super(**args)
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def resolve!
        game.choices.add(ScryChoice.new(actor: self, amount: 1))
      end
    end
  end
end
