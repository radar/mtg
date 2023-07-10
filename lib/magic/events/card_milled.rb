module Magic
  module Events
    class CardMilled
      def initialize(player:, card:)
        @player = player
        @card = card
      end
    end
  end
end
