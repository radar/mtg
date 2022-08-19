module Magic
  module Effects
    class DrawCards < Effect
      attr_reader :player, :number_to_draw

      def initialize(player:, number_to_draw: 1, **args)
        @player = player
        @number_to_draw = number_to_draw
        super(**args)
      end

      def resolve
        number_to_draw.times do

          player.draw!
        end
      end
    end
  end
end
