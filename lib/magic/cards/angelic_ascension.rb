module Magic
  module Cards
    AngelicAscension = Instant("Angelic Ascension") do
      cost generic: 1, white: 1
    end

    class AngelicAscension
      def resolution_effects
        [
          Effects::SingleTargetAndResolve.new(
            choices: game.battlefield.select { |c| c.creature? || c.planeswalker? },
            targets: 1,
            resolution: -> (target) {
              target.exile!
              token = Tokens::Angel.new(game: game)
              token.controller = target.controller
              token.resolve!
            }
          )
        ]
      end
    end
  end
end
