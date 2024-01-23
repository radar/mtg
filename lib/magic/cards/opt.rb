module Magic
  module Cards
    Opt = Instant("Opt") do
      cost blue: 1
    end

    class Opt < Instant
      def resolve!
        game.add_effect(
          Effects::Scry.new(source: self, amount: 1, then_do: -> do
            trigger(:draw_card)
          end)
        )

        super
      end
    end
  end
end
