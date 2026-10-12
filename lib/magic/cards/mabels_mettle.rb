module Magic
  module Cards
    MabelsMettle = Instant("Mabel's Mettle") do
      cost generic: 1, white: 1
    end

    class MabelsMettle < Instant
      def multi_target? = true

      def target_choices
        [
          battlefield.creatures,
          (battlefield.creatures - [self]),
        ]
      end

      def resolve!(targets:)
        pump(targets[0], 2, 2)
        pump(targets[1], 1, 1)
      end
    end
  end
end
