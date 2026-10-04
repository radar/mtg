module Magic
  module Cards
    SecondHarvest = Instant("Second Harvest") do
      cost generic: 2, green: 2
    end

    class SecondHarvest < Instant
      # "For each token you control, create a token that's a copy of that permanent." The tokens
      # are fixed before any copy is made, so the new copies aren't copied again.
      def resolve!
        tokens = battlefield.controlled_by(controller).select(&:token?)
        tokens.each do |token|
          Permanent.resolve(game: game, owner: controller, card: token.copiable_card, token: true, copy: true, cast: false)
        end
      end
    end
  end
end
