module Magic
  module Cards
    class DragToTheRoots < Instant
      card_name "Drag to the Roots"
      cost "{2}{B}{G}"

      # "Delirium — This spell costs {2} less to cast as long as there are four or more card types among cards in your
      # graveyard."
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { player.graveyard.delirium? ? -2 : 0 } }
      end

      def single_target? = true

      def target_choices = battlefield.reject(&:land?)

      # "Destroy target nonland permanent."
      def resolve!(target:)
        trigger_effect(:destroy_target, target:)
      end
    end
  end
end
