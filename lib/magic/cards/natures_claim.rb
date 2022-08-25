module Magic
  module Cards
    class NaturesClaim < Instant
      NAME = "Nature's Claim"
      COST = { green: 1 }

      def target_choices
        battlefield.permanents.by_any_type("Enchantment", "Artifact")
      end

      def single_target?
        true
      end

      def resolve!(_controller, target:)
        target.destroy!
        target.controller.gain_life(4)

        super
      end
    end
  end
end
