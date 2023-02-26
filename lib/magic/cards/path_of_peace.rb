module Magic
  module Cards
    PathOfPeace = Sorcery("Path of Peace") do
      cost generic: 3, white: 1
    end

    class PathOfPeace < Sorcery
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
