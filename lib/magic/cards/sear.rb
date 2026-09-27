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
        trigger_effect(:deal_damage, target: target, damage: 4)
      end
    end
  end
end
