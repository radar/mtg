module Magic
  module Events
    # `player` promised a gift and `recipient` (an opponent) received it ("Whenever you give a gift").
    class GiftGiven
      attr_reader :player, :recipient

      def initialize(player:, recipient:)
        @player = player
        @recipient = recipient
      end
    end
  end
end
