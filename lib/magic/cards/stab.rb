module Magic
  module Cards
    Stab = Instant("Stab") do
      cost black: 1
    end

    class Stab < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        pump(target, -2, -2)
      end
    end
  end
end
