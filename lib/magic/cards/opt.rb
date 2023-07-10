module Magic
  module Cards
    Opt = Instant("Opt") do
      cost blue: 1
    end

    class Opt < Instant
      def resolve!(_controller)
        game.add_effect(
          Effects::Scry.new(source: self, amount: 1, then_do: -> do
            game.add_effect(Effects::DrawCards.new(source: self, player: controller))
          end)
        )

        super
      end
    end
  end
end
