module Magic
  module Cards
    class RakdosCharm < Instant
      card_name "Rakdos Charm"
      cost black: 1, red: 1

      def resolve!
        controller.opponents.each { |opponent| opponent.graveyard.items.clear }
      end
    end
  end
end