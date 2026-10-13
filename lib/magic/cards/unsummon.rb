module Magic
  module Cards
    Unsummon = Instant("Unsummon") do
      cost blue: 1
    end

    class Unsummon < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        bounce(target)
      end
    end
  end
end
