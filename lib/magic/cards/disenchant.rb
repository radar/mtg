module Magic
  module Cards
    Disenchant = Instant("Disenchant") do
      cost generic: 1, white: 1
    end

    class Disenchant < Instant
      def target_choices
        (battlefield.artifacts + battlefield.enchantments)
      end

      def resolve!(target:)
        trigger_effect(:destroy_target, target: target)
      end
    end
  end
end
