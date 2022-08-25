module Magic
  module Cards
    AngelicAscension = Instant("Angelic Ascension") do
      cost generic: 1, white: 1
    end

    class AngelicAscension

      def single_target?
        true
      end

      def target_choices
        battlefield.select { |c| c.creature? || c.planeswalker? }
      end

      def resolve!(_controller, target:)
        target.exile!

        Permanent.resolve(game: game, controller: target.controller, card: Tokens::Angel.new)
      end
    end
  end
end
