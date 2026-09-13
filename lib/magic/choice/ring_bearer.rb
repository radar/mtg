module Magic
  class Choice
    class RingBearer < Targeted
      def initialize(player:)
        @player = player
        super(actor: player)
      end

      def controller = @player
      def choices = @player.creatures
      def choice_amount = 1

      def resolve!(target:)
        @player.ring_bearer&.ring_bearer = false
        target.ring_bearer = true
        @player.ring_bearer = target
      end
    end
  end
end
