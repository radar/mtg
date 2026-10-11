module Magic
  module Events
    # +player+ manifested dread: +permanent+ is the face-down creature that resulted, +graveyard_card+ the card they put into
    # their graveyard that way (nil when only one card was left in the library).
    class ManifestedDread < Base
      attr_reader :player, :permanent, :graveyard_card

      def initialize(player:, permanent:, graveyard_card: nil)
        @player = player
        @permanent = permanent
        @graveyard_card = graveyard_card
      end

      def inspect
        "#<Events::ManifestedDread player: #{player.name}, permanent: #{permanent.card.name}>"
      end
    end
  end
end
