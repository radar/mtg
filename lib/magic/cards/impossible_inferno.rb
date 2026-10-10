module Magic
  module Cards
    class ImpossibleInferno < Instant
      card_name "Impossible Inferno"
      cost generic: 4, red: 1

      def single_target? = true

      def target_choices = battlefield.select(&:creature?)

      # "Impossible Inferno deals 6 damage to target creature.
      # Delirium — If there are four or more card types among cards in your graveyard, exile the top card of your
      # library. You may play it until the end of your next turn."
      def resolve!(target:)
        trigger_effect(:deal_damage, damage: 6, target:)
        return unless controller.graveyard.delirium?

        top = controller.library.first or return
        trigger_effect(:exile, target: top)
        game.play_permissions.grant_until_end_of_next_turn(card: top, player: controller)
      end
    end
  end
end
