module Magic
  module Effects
    class AddManaOrAbility < Effect
      attr_reader :player, :white, :blue, :black, :red, :green

      def initialize(player:, white: 0, blue: 0, black: 0, red: 0, green: 0, **args)
        @player = player
        @white = white
        @blue = blue
        @black = black
        @red = red
        @green = green

        super(**args)
      end

      def requires_choices?
        true
      end

      def single_choice?
        false
      end

      def resolve(mana)
        player.add_mana(mana)
      end
    end
  end
end
