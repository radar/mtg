module Magic
  module Events
    class EnterTheBattlefield
      attr_reader :card

      def initialize(card)
        @card = card
      end
    end
  end
end
