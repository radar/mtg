module Magic
  module Cards
    ComeBackWrong = Sorcery("Come Back Wrong") do
      cost generic: 2, black: 1
    end

    class ComeBackWrong < Sorcery
      def target_choices = battlefield.creatures

      # "Destroy target creature. If a creature card is put into a graveyard this way, return it to the battlefield
      # under your control. Sacrifice it at the beginning of your next end step."
      def resolve!(target:)
        return if target.token?

        card = target.card
        trigger_effect(:destroy_target, target: target)
        return unless card.creature? && card.zone&.graveyard?

        returned = Permanent.put_onto_battlefield(game: game, card: card, from_zone: card.zone, controller: controller)
        returned.register_turn_trigger(Events::BeginningOfEndStep, Blitz::EndStepSacrificeTrigger)
      end
    end
  end
end
