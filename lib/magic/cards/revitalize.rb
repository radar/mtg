module Magic
  module Cards
    class Revitalize < Instant
      NAME = "Revitalize"
      COST = { generic: 1, white: 1 }

      def resolve!
        add_effect("YouGainLife", life: 3)
        add_effect("DrawCards", player: controller)
      end
    end
  end
end
