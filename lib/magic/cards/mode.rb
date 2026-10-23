module Magic
  module Cards
    class Mode
      include Shared::Events

      attr_reader :game, :card

      # The X the spell was cast with, set by Cast#choose_mode ("Target player creates X ... tokens").
      attr_accessor :x_value

      # The {P} a mode of a Season costs (`points 2`); 1 by default.
      def self.points(count = nil)
        @points = count if count
        @points || 1
      end

      def points = self.class.points

      def initialize(game:, card:)
        @game = game
        @card = card
      end

      def controller
        card.controller
      end

      # Effects a mode triggers name their source (in logs and events): the card the mode belongs to.
      def name
        card.name
      end

      def source
        card
      end

      # Rule 113.7: the source of a mode's effects is the card, not the mode.
      def trigger_effect(effect, **args)
        super(effect, **{ source: source }.merge(args))
      end

      def battlefield
        game.battlefield
      end

    end
  end
end
