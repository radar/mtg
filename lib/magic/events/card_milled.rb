module Magic
  module Events
    class CardMilled
      attr_reader :player, :card

      def initialize(player:, card:)
        @player = player
        @card = card
      end
    end
  end
end
