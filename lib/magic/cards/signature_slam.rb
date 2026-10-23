module Magic
  module Cards
    SignatureSlam = Instant("Signature Slam") do
      cost generic: 2, green: 1
    end

    class SignatureSlam < Instant
      def multi_target? = true

      def target_choices
        [battlefield.controlled_by(controller).creatures, battlefield.not_controlled_by(controller).creatures]
      end

      # "Put a +1/+1 counter on target creature you control, then each modified creature you control deals damage equal
      # to its power to target creature you don't control."
      def resolve!(targets:)
        mine, victim = targets
        add_counter "+1/+1", to: mine
        controller.creatures.select(&:modified?).each { _1.bite!(victim) }
      end
    end
  end
end
