module Magic
  module Cards
    class InfernalGrasp < Instant
      card_name "Infernal Grasp"
      cost generic: 1, black: 1

      def target_choices = battlefield.creatures

      def resolve!(target:)
        trigger_effect(:destroy_target, target: target)
        controller.lose_life(2)
      end
    end
  end
end