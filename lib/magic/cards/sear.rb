module Magic
  module Cards
    Sear = Instant("Sear") do
      cost generic: 1, red: 1
    end

    class Sear < Instant
      def target_choices
        battlefield.creatures + battlefield.planeswalkers
      end

      def resolve!(target:)
        deal_damage(4, to: target)
      end
    end
  end
end
