module Magic
  module Cards
    Murder = Instant("Murder") do
      cost generic: 1, black: 2
    end

    class Murder < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        destroy(target)
      end
    end
  end
end
