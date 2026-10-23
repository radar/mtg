module Magic
  module Cards
    AbstruseAppropriation = Instant("Abstruse Appropriation") do
      cost generic: 2, white: 1, black: 1
      keywords :devoid
    end

    class AbstruseAppropriation < Instant
      def target_choices
        battlefield.permanents.reject(&:land?)
      end

      # Exile target nonland permanent. You may cast that card for as long as it remains exiled, and you may spend
      # colorless mana as though it were mana of any color to cast that spell.
      def resolve!(target:)
        card = target.card
        exile_target(target)
        return if target.token?

        game.play_permissions.grant_while_exiled(card: card, player: controller, any_mana: true)
      end
    end
  end
end
