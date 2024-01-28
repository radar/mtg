module Magic
  module Cards
    Opt = Instant("Opt") do
      cost blue: 1
    end

    class Opt < Instant
      class Choice < Magic::Choice::Scry
        def resolve!(**args)
          super(**args)
          source.trigger_effect(:draw_cards)
        end
      end

      def resolve!
        game.choices.add(Choice.new(source: self, amount: 1))

        super
      end
    end
  end
end
