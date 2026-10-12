module Magic
  module Cards
    class RepelCalamity < Instant
      card_name "Repel Calamity"
      cost generic: 1, white: 1

      def target_choices
        battlefield.creatures.select { _1.power >= 4 || _1.toughness >= 4 }
      end

      def resolve!(target:)
        trigger_effect(:destroy_target, target: target)
      end
    end
  end
end
