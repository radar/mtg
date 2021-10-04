module Magic
  module Cards
    AngelicAscension = Instant("Angelic Ascension") do
      cost generic: 1, white: 1
    end

    class AngelicAscension
      def resolution_effects
        [
          Effects::ExileTargetControllerCreatesAToken.new(
            choices: game.battlefield.select { |c| c.creature? || c.planeswalker? },
            token: Tokens::Angel.new(game: game)
          )
        ]
      end
    end
  end
end
