module Magic
  module Cards
    class PathOfPeace < Sorcery
      NAME = "Path of Peace"
      COST = { generic: 3, white: 1 }


      def target_choices
        battlefield.creatures
      end

      def single_target?
        true
      end

      def resolve!(controller, target:)
        target.destroy!
        target.controller.gain_life(4)

        super(controller)
      end
    end
  end
end
