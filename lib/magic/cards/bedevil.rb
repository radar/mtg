module Magic
  module Cards
    class Bedevil < Instant
      card_name "Bedevil"
      cost black: 2, red: 1

      def single_target? = true

      def target_choices
        battlefield.permanents.select { _1.artifact? || _1.creature? || _1.planeswalker? }
      end

      # "Destroy target artifact, creature, or planeswalker."
      def resolve!(target:)
        trigger_effect(:destroy_target, target: target)
      end
    end
  end
end
