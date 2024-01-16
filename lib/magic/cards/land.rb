module Magic
  module Cards
    class Land < Card
      type "Land"

      def play!
        move_zone!(game.battlefield)
      end
    end
  end
end
