module Magic
  module Cards
    class Land < Card
      def play!
        move_zone!(game.battlefield)
      end
    end
  end
end
