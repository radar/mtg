module Magic
  module Cards
    class Revitalize < Instant
      NAME = "Revitalize"
      COST = { generic: 1, white: 1 }

      def resolve!(controller)
        controller.gain_life(3)
        controller.draw!

        super
      end
    end
  end
end
