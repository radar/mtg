module Magic
  module Effects
    class AddManaOrAbility
      attr_reader :player, :white, :blue, :black, :red, :green

      def initialize(player:, white: 0, blue: 0, black: 0, red: 0, green: 0)
        @player = player
        @white = white
        @blue = blue
        @black = black
        @red = red
        @green = green
      end

      def choose(color)
        player.add_mana(color)
      end
    end
  end
end
