module Magic
  module Actions
    class Cast
      # Pays the card's blitz cost; the permanent gains haste, draws its controller a card when it dies, and is
      # sacrificed at the beginning of the next end step.
      class Blitz < Cast
        private

        def base_cost = card.blitz_cost

        def plain_cost? = false

        def after_resolving(resolved)
          return unless resolved.is_a?(Permanent)

          resolved.grant_haste!
          resolved.register_turn_trigger(Events::CreatureDied, Magic::Blitz::DeathDrawTrigger)
          resolved.register_turn_trigger(Events::BeginningOfEndStep, Magic::Blitz::EndStepSacrificeTrigger)
        end
      end
    end
  end
end
