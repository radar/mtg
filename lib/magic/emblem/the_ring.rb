module Magic
  class Emblem
    class TheRing < Emblem
      MAX_LEVEL = 4

      attr_reader :level

      def initialize(game:, owner:)
        super
        @level = 0
      end

      def gain_next_ability!
        @level = [@level + 1, MAX_LEVEL].min
      end
    end
  end
end
