module Magic
  module Cards
    class ChaosWarp < Instant
      card_name "Chaos Warp"
      cost generic: 2, red: 1

      def target_choices
        battlefield.permanents
      end

      def resolve!(target:)
        owner = target.owner
        trigger_effect(:exile, target: target)
        owner.library.shuffle!
      end
    end
  end
end