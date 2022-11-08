module Magic
  module Cards
    Revitalize = Instant("Revitalize") do
      cost generic: 1, white: 1
    end

    class Revitalize < Instant
      def resolve!(controller)
        controller.gain_life(3)
        controller.draw!

        super
      end
    end
  end
end
