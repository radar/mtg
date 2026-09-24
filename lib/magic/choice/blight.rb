module Magic
  class Choice
    # Blight N: `player` puts N -1/-1 counters on a creature they control. With no
    # creature there is nothing to choose, so callers add this only when `possible?`.
    class Blight < Targeted
      attr_reader :amount, :player

      def self.possible?(player, game) = game.battlefield.controlled_by(player).creatures.any?

      def initialize(actor:, amount:, player: actor.controller)
        @amount = amount
        @player = player
        super(actor: actor)
      end

      def choices = battlefield.controlled_by(player).creatures

      def choice_amount = 1

      def resolve!(target:)
        trigger_effect(:add_counter, counter_type: Counters::Minus1Minus1, target: target, amount: amount)
      end
    end
  end
end
