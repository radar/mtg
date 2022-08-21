module Magic
  module Cards
    AngelicAscension = Instant("Angelic Ascension") do
      cost generic: 1, white: 1
    end

    class AngelicAscension

      def target_choices
        battlefield.select { |c| c.creature? || c.planeswalker? }
      end

      def resolve!(target:)
        target.exile!

        Permanent.resolve(game: game, controller: controller, card: Tokens::Angel.new)
      end
    end
  end
end
