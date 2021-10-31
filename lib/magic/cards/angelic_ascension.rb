module Magic
  module Cards
    AngelicAscension = Instant("Angelic Ascension") do
      cost generic: 1, white: 1
    end

    class AngelicAscension

      def target_choices
        game.battlefield.select { |c| c.creature? || c.planeswalker? }
      end

      def resolve!(target:)
        target.exile!
        token = Tokens::Angel.new(game: game)
        token.controller = target.controller
        token.resolve!
      end
    end
  end
end
