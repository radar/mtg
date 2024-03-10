module Magic
  module Effects
    class DrawCards < Effect
      attr_reader :player, :number_to_draw

      def initialize(player: nil, number_to_draw: 1, **args)
        super(**args)
        @player = player || source.controller
        @number_to_draw = number_to_draw
      end

      def inspect
        "#<Effects::DrawCards player:#{player.name} number_to_draw:#{number_to_draw}>"
      end

      def resolve!
        number_to_draw.times do
          player.draw!
        end
      end
    end
  end
end
